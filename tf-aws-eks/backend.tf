terraform {
  backend "s3" {
    bucket = "terraform-eks-cicd-namkj0428"
    # key    = "eks/terraform.tfstate"
    key = "eks/$TF_WORKSPACE/terraform.tfstate"
    region = "ap-northeast-2"
  }
}