terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.69.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3.0"
    }    
  }  
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
