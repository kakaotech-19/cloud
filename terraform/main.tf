provider "aws" {
  region = "ap-northeast-2" # 원하는 지역으로 설정
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"

  cloud {
    organization = "todak"

    workspaces {
      name = "todak-terraform"
    }
  }
}
