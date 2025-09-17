data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_iam_policy_document" "alb_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

# ----------------------------------------------------------
# IAM Policy for AWS Load Balancer Controller
# ----------------------------------------------------------
data "http" "aws_lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.1/docs/install/iam_policy.json"
}