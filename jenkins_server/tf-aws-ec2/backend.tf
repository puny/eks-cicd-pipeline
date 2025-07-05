terraform {
  backend "s3" {
    bucket = "terraform-eks-cicd-namkj0428"
    key    = "jenkins/terraform.tfstate"
    region = "ap-northeast-2"
  }
}