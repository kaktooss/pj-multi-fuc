resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "helm_release" "consul" {
  name = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "1.2.0"

  namespace = kubernetes_namespace.consul.metadata[0].name

  values = [
    templatefile("values/consul.yaml", {
      consul_ingress_domain = var.ingress_domain
    }),
  ]

  max_history = var.helm_max_history
}
