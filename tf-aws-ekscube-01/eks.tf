# Ref - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.4"

  name                = var.eks_cluster_name
  iam_role_arn        = aws_iam_role.eks_cluster_role.arn
  kubernetes_version  = var.eks_cluster_version
  subnet_ids          = module.vpc.private_subnets
  vpc_id              = module.vpc.vpc_id
  # configmap & api 
  authentication_mode   = "API"
  # authentication_mode = "API_AND_CONFIG_MAP"

  # service account 직접정의
  /* 
  service_accounts = {
    aws_load_balancer_controller = {
      name = "aws-load-balancer-controller"
      namespace = "kube-system"

      role_name_prefix = "alb-controller-"
    } 
  } */
    
  addons = {
    coredns                = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      before_compute = true
      most_recent = true      
    }
    kube-proxy             = {
      most_recent = true
    }
    vpc-cni                = {
      before_compute = true
      most_recent = true
    }
  }
  
  # IRSA 활성화
  # OIDC provider 자동으로 생성됨
  enable_irsa = true
  
  # Optional
  endpoint_public_access = true
  # endpoint_public_access_cidrs = [ "0.0.0.0/0" ]
  endpoint_private_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # compute_config = {
  #   enabled    = true
  #   node_pools = ["general-purpose"]
  # }

  # aws-auth ConfigMap 매핑
  # manage_aws_auth_configmap = true
  # map_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::533267419021:role/air-dev-assume-workshop-role"
  #     username = "eks-admin"
  #     groups   = ["system:masters"]
  #   }
  # ]

  eks_managed_node_groups = {
    nodes = {
      
      iam_role_arn = aws_iam_role.eks_node_role.arn

      desired_size = 1
      min_size = 1
      max_size = 3

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

resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${var.aws_region}"
    interpreter = ["/bin/bash", "-c"]
  }
}