resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name = "metallb"

  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.10"

  namespace = kubernetes_namespace.metallb.metadata[0].name
}


data "kubectl_path_documents" "metallb_resources" {
  pattern = "./resources-metallb/*.yaml"

  vars = {
    lb_address_pool : var.lb_address_pool
  }
}

resource "kubectl_manifest" "metallb_resources" {
  depends_on = [helm_release.metallb]

  count     = length(data.kubectl_path_documents.metallb_resources.documents)
  yaml_body = element(data.kubectl_path_documents.metallb_resources.documents, count.index)
}