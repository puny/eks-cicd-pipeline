terraform {
  backend "s3" {
    # bucket = "terraform-eks-cicd-namkj0428"
    bucket = "namkj-terraform-on-aws-eks"
    key    = "dev/workshop01/terraform.tfstate"
    region = "ap-northeast-2"
  }
}