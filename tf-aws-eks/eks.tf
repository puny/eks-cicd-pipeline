# Ref - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21.0"

  cluster_name    = "eks-cicd-cluster"
  cluster_version = "1.28"

  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["t3a.small", "t3a.medium", "t3a.large", "t3.small", "t3.medium", "t3.large"]
  }

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      # instance_types = ["t2.small"]
      instance_types = [var.instance_type]
      # capacity_type = "ON_DEMAND"      
      capacity_type = "SPOT"
      max_price = "0.009"
    }
  }

  tags = {
    cost = "eks-cicd-pipeline"
    Environment = "dev"
    Terraform   = "true"    
  }
}