#!/bin/bash

echo "Fetching AWS Resources Information..."

# Function to check and print resources
check_and_print() {
  local title=$1
  local command=$2
  local output

  output=$(eval $command)

  if [ -n "$output" ]; then
    echo -e "\n$title"
    echo "$output"
  fi
}

# IAM 사용자 조회
check_and_print "IAM Users" "aws iam list-users --query \"Users[*].[UserName, UserId, Arn]\" --output table"

# EC2 인스턴스 조회
check_and_print "EC2 Instances" "aws ec2 describe-instances --query \"Reservations[*].Instances[*].[InstanceId, State.Name, PublicIpAddress]\" --output table"

# S3 버킷 조회
check_and_print "S3 Buckets" "aws s3 ls"

# RDS 인스턴스 조회
check_and_print "RDS Instances" "aws rds describe-db-instances --query \"DBInstances[*].[DBInstanceIdentifier, DBInstanceStatus, Endpoint.Address]\" --output table"

# ELB 조회
check_and_print "Elastic Load Balancers" "aws elb describe-load-balancers --query \"LoadBalancerDescriptions[*].[LoadBalancerName, DNSName]\" --output table"

# ALB/NLB 조회
check_and_print "Application/Network Load Balancers" "aws elbv2 describe-load-balancers --query \"LoadBalancers[*].[LoadBalancerName, DNSName, State.Code]\" --output table"

# Lambda 함수 조회
check_and_print "Lambda Functions" "aws lambda list-functions --query \"Functions[*].[FunctionName, Runtime, LastModified]\" --output table"

# VPC 조회
check_and_print "VPCs" "aws ec2 describe-vpcs --query \"Vpcs[*].[VpcId, Tags[?Key=='Name'].Value | [0], CidrBlock, State]\" --output table"

# DynamoDB 테이블 조회
check_and_print "DynamoDB Tables" "aws dynamodb list-tables --query \"TableNames\" --output table"

# EKS 클러스터 상세 조회
eks_clusters=$(aws eks list-clusters --query "clusters" --output text)
if [ -n "$eks_clusters" ]; then
  echo -e "\n==== EKS Clusters Details ===="
  for cluster in $eks_clusters; do
    echo -e "\nDetails for Cluster: $cluster"
    aws eks describe-cluster --name $cluster --query "cluster.[name, status, endpoint, platformVersion, resourcesVpcConfig.subnetIds]" --output table
  done
fi
