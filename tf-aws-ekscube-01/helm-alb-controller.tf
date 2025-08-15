
# ------------------------------
# Helm Install aws-load-balancer-controller
# ------------------------------

resource "helm_release" "alb_controller" {
  depends_on = [    
    module.eks,
    module.vpc,
    aws_iam_role_policy_attachment.alb_controller_attach
  ]

  name        = "aws-load-balancer-controller"
  namespace   = "kube-system"
  repository  = "https://aws.github.io/eks-charts"
  chart       = "aws-load-balancer-controller"

  set {
    name = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name = "serviceAccount.create"
    value = "false"
  }
  set {
    name = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }
  set {
    name = "region"
    value = var.aws_region
  }
  set {
    name = "vpcId"
    value = module.vpc.vpc_id
  }
}
