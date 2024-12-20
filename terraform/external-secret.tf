# Kubernetes 에서 민감한 정보들을 AWS Secret Manager을 통해서 관리하고, 가져와서 사용하기 위해 필요한 리소스들이다.


data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

# Kubernetes Provider 설정
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# AWS 현재 계정 정보
data "aws_caller_identity" "current" {}

# AWS IAM 정책 생성
resource "aws_iam_policy" "external_secrets_policy" {
  name        = "ExternalSecretsPolicy"
  description = "Policy to allow access to AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:ap-northeast-2:${data.aws_caller_identity.current.account_id}:secret:*"
      }
    ]
  })
}

# AWS IAM 역할 생성
resource "aws_iam_role" "external_secrets_role" {
  name = "ExternalSecretsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa",
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# IAM 정책과 역할 연결
resource "aws_iam_role_policy_attachment" "external_secrets_policy_attachment" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}

# external-secrets 네임스페이스 생성
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

# Kubernetes Service Account 생성
resource "kubernetes_service_account" "external_secrets_sa" {
  metadata {
    name      = "external-secrets-sa"
    namespace = "external-secrets"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_role.arn
    }
  }
}