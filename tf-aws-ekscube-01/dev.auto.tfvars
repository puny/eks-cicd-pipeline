aws_region = "ap-northeast-2"
# 주계정 아이디
# aws_account_id = "813307607383"
aws_account_id = "533267419021"
vpc_name       = "eks-cluster-vpc"
vpc_cidr       = "10.12.0.0/16"
public_subnets = ["10.12.0.0/24", "10.12.1.0/24"]
private_subnets = ["10.12.2.0/24", "10.12.3.0/24"]
instance_type  = "t3a.small"
eks_cluster_name = "eks-cicd-cluster"
eks_cluster_version = "1.33"
backend_bucket = "terraform-eks-cicd-namkj0428"
# 주계정 backend bucket
# backend_bucket = "cotton-terraform-eks"
