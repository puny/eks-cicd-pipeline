# Ref - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.14.0"

  name                = var.eks_cluster_name
  iam_role_arn        = aws_iam_role.eks_cluster_role.arn
  kubernetes_version  = var.eks_cluster_version
  subnet_ids          = module.vpc.private_subnets
  vpc_id              = module.vpc.vpc_id

  # configmap & api 
  authentication_mode   = "API"
  # authentication_mode = "API_AND_CONFIG_MAP"

  # eks cluster access entry 정의
  access_entries = {
    # 사용자 식별자 (임의 지정 가능)
    puny_user = {
      principal_arn     = "arn:aws:iam::813307607383:user/puny"
      type              = "STANDARD"

      policy_associations = {
        # 1. Cluster Admin 정책 (클러스터 전체 제어)
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        # 2. Admin 정책 (일반적인 관리 권한)
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

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
    # aws ebs csi driver addon 추가
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.arn
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
        changed_by = "terraform"
        deploy = "true"
      }
    }
  }

  tags = {
    Name = var.eks_cluster_name
    cost = var.eks_cluster_name    
  }
}

# 이거 제대로 되지 않은거 같아서 확인 해봐야함
module "eks_load_balancer_controller" {
  depends_on = [module.eks]

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.3.0"

  name = "aws-load-balancer-controller"
  
  # 해당 Role을 사용할 Service Account 지정 (namespace:name 형식)
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:aws-load-balancer-controller"]
    }
  }

  # 권한 정책 (예: S3 읽기 전용)
  policies = {
    policy = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

}


# resource "aws_iam_policy" "load_balancer_controller" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   path        = "/"
#   description = "IAM policy for AWS Load Balancer Controller (v2.13.3)"

#   # data.http를 통해 받은 응답의 body를 정책으로 사용
#   policy = data.http.lb_controller_policy_json.response_body
# }


# eks aws controller for kubernetes s3
/*
module "eks-ack-addons" {
  depends_on = [module.eks]

  source  = "aws-ia/eks-ack-addons/aws"
  version = "3.0.3"
  # insert the 3 required variables here

  cluster_name        = "${var.eks_cluster_name}"
  cluster_endpoint    = "${module.eks.cluster_endpoint}"
  oidc_provider_arn   = "${module.eks.oidc_provider_arn}"

  enable_s3       = true

  tags = {
    Name = "${var.eks_cluster_name}-ack-addon"
    cost = "${var.eks_cluster_name}-ack-addon"
  }
}
*/

resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${var.aws_region}"
    interpreter = ["/bin/bash", "-c"]
  }
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Name = "eks-cicd-cluster-module-karpenter"
    cost = "eks-cicd-cluster-module-karpenter"
    Environment = "dev"
    Terraform   = "true"
  }
}


# ebs csi driver addon
module "ebs_csi_driver_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.3.0"

  name = "ebs-csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    this = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Name = "eks-cicd-cluster-ebs-csi-driver-irsa"
    cost = "eks-cicd-cluster-ebs-csi-driver-irsa"
    Terraform   = "true"
    Environment = "dev"
  }
}
