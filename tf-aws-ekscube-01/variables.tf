variable "aws_region" {
    description = "The region where the infrastructure should be deployed to"
    type        = string
}

variable "aws_account_id" {
    description = "AWS Account ID"
    type        = string
}

variable "eks_cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
    default     = "eks-cicd-cluster"
}

variable "eks_cluster_version" {
    description = "Version of the EKS cluster"
    type        = string
    default     = "1.28"
}

variable "vpc_name" {
  description = "VPC Name for EKS Cluster VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for EKS Cluster VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public Subnets CIDR range"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private Subnets CIDR range"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance Type for EKS Nodes"
  type        = string
}


variable "node_min_size" {
  description = "Node Minimum Size"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Node Maximum Size"
  type        = number
  default     = 3
}

variable "backend_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "terraform-eks-cicd-namkj0428"
}