aws_region = "ap-northeast-2"
aws_account_id = "533267419021"
vpc_name       = "eks-cicd-vpc"
vpc_cidr       = "11.12.0.0/16"
public_subnets = ["11.12.1.0/24", "11.12.2.0/24", "11.12.3.0/24"]
private_subnets = ["11.12.11.0/24", "11.12.12.0/24", "11.12.13.0/24"]
instance_type  = "t3a.small"
