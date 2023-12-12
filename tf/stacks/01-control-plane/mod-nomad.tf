resource "kubernetes_namespace" "nomad" {
  metadata {
    name = "nomad"
  }
}

resource "kubernetes_manifest" "nomad_server_config" {
  depends_on = [kubernetes_namespace.nomad]

  manifest = yamldecode(file("${path.module}/resources/nomad-server-config.yaml"))
}


resource "kubernetes_service_v1" "nomad" {
  metadata {
    name      = "nomad"
    namespace = kubernetes_namespace.nomad.metadata[0].name
    labels = {
      app = "nomad"
    }
  }

  spec {
    selector = {
      app = "nomad"
    }

    type             = "LoadBalancer"
    load_balancer_ip = "192.168.1.13"

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 4646
      target_port = 4646
    }

    port {
      name        = "rpc"
      protocol    = "TCP"
      port        = 4647
      target_port = 4647
    }
  }
}

resource "kubernetes_ingress_v1" "nomad" {
  metadata {
    name      = "nomad"
    namespace = kubernetes_namespace.nomad.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "nomad.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.nomad.metadata[0].name
              port {
                number = 4646
              }
            }
          }
        }
      }
    }
  }
}