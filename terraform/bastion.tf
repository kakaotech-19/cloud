resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = module.vpc.vpc_id

  # SSH 접근 허용 (퍼블릭 IP에서 Bastion으로 접근)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 허용할 IP 범위 (예: 회사 IP 또는 VPN IP)
  }

  # 프라이빗 네트워크에서의 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-0f1e61a80c7ab943e" # Amazon Linux 2 AMI (리전별 AMI ID 확인 필요)
  instance_type = "t2.micro"
  key_name      = "todak" # 이미 생성된 Key Pair 이름
  vpc_security_group_ids = [aws_security_group.bastion_sg.id] # 보안 그룹 ID 사용

  # EKS와 동일한 VPC와 서브넷 사용
  subnet_id = module.vpc.public_subnets[0] # 퍼블릭 서브넷 사용

  tags = {
    Name = "Bastion Host"
  }
}