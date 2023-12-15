resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}


resource "helm_release" "nginx_ingress" {
  depends_on = [helm_release.metallb, kubectl_manifest.metallb_resources]

  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.1.4"

  namespace = kubernetes_namespace.ingress.metadata[0].name

  values = [
    file("values/ingress-nginx.yaml"),
  ]

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ingress_ip
  }
}
