# Ref - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21.0"

  cluster_name    = "workshop-eks-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets


  # eks_managed_node_groups = {
  #   nodes = {
  #     min_size     = 0
  #     max_size     = 3
  #     desired_size = 0

  #     # instance_types = ["t2.small"]
  #     instance_type = var.instance_type
  #     capacity_type  = "SPOT"
  #     # capacity_type = "ON_DEMAND"
  #   }
  # }

  tags = {
    cost = "workshop-eks-cicd-pipeline"
    Environment = "dev"
    Terraform   = "true"    
  }
}