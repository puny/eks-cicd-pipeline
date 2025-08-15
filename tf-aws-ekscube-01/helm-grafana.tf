resource "helm_release" "grafana" {
  depends_on = [
    helm_release.alb_controller
  ]
  name       = "my-grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitor"

  values = [
    yamlencode({
      ingress = {
        enabled = true
        ingressClassName = "alb" # AWS ALB Controller 사용
        annotations = {
          "alb.ingress.kubernetes.io/scheme"         = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"    = "ip"
          "alb.ingress.kubernetes.io/listen-ports"   = "[{\"HTTP\":80}]"
        }
        hosts = []
        path  = "/grafana"
        pathType = "Prefix"        
      }
      service = {
        name = "nginx-service"
        type = "ClusterIP"
        tags = {
          Name = "${var.eks_cluster_name}-alb"
          cost = "${var.eks_cluster_name}-alb"
        }
      }
      adminPassword = "admin123" # 초기 비밀번호
    })
  ]
}