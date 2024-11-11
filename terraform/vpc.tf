module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name                    = "eks-vpc"
  cidr                    = "10.0.0.0/16"
  azs                     = ["ap-northeast-2a", "ap-northeast-2b"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true //퍼블릭 ip자동할당
}

# 보안 그룹 정의 - eks-cluster-sg
resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "eks-cluster-sg"

  # EKS 클러스터 API 서버 포트
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 필요에 따라 IP 범위를 제한
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 필요에 따라 IP 범위를 제한
  }

}

# 보안 그룹 정의 - eks-node-sg
resource "aws_security_group" "eks_node_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "eks-node-sg"

  # 모든 노드 간 통신 허용 (Kubernetes 내부 통신용)
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  # 클러스터 보안 그룹과 노드 간의 통신 허용
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  # 아웃바운드 인터넷 트래픽 허용 (NAT 게이트웨이 사용 시 필요)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}