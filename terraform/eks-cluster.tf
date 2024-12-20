module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = "eks-cluster"
  cluster_version = "1.31"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # ingress를 위한 클러스터 엔드포인트 접근 허용
  cluster_endpoint_public_access = true

  # 클러스터 보안 그룹 추가
  cluster_additional_security_group_ids=[aws_security_group.eks_cluster_sg.id]

  # EKS 클러스터 IAM 역할
  iam_role_name = aws_iam_role.eks_cluster_role.name

  # node Group 추가
  eks_managed_node_groups = {
    eks-managed-node-group = {

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      iam_role_arn = aws_iam_role.eks_worker_node_role.arn
      vpc_security_group_ids= [aws_security_group.eks_node_sg.id]

      key_name      = "todak" # 이미 생성된 Key Pair 이름
    }
  }

}
