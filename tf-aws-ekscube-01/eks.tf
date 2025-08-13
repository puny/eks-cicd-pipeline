# Ref - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.4"

  name    = var.eks_cluster_name
  iam_role_arn = aws_iam_role.eks_cluster_role.arn
  kubernetes_version = var.eks_cluster_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  authentication_mode = "API"
  # configmap & api 
  # authentication_mode = "API_AND_CONFIG_MAP"
    
  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }
  
  
  # Optional
  endpoint_public_access = true
  endpoint_public_access_cidrs = [ "0.0.0.0/0" ]

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # compute_config = {
  #   enabled    = true
  #   node_pools = ["general-purpose"]
  # }

  eks_managed_node_groups = {
    nodes = {
      
      iam_role_arn = aws_iam_role.eks_node_role.arn

      min_size = 1
      max_size = 3
      desired_capacity = 1

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.instance_type]
      capacity_type  = "SPOT"
      tags = {
        Name = "${var.eks_cluster_name}-node"
        cost = "${var.eks_cluster_name}-node"
      }
    }
  }

  tags = {
    Name = var.eks_cluster_name
    cost = var.eks_cluster_name
  }
}

/* 
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.22.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller    = true
  enable_cluster_proportional_autoscaler = true
  enable_karpenter                       = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
  # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }
} */