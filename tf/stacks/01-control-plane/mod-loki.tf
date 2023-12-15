#resource "kubernetes_namespace_v1" "loki" {
#  metadata {
#    name = "loki"
#  }
#}
#
#locals {
#  loki_upstream = "loki-gw.micro.codehound.cz"
#}
#
#resource "kubernetes_service_v1" "loki" {
#  metadata {
#    name      = "loki-remote"
#    namespace = kubernetes_namespace_v1.loki.metadata[0].name
#  }
#
#  spec {
#    type          = "ExternalName"
#    external_name = local.loki_upstream
#  }
#}
#
#resource "kubernetes_ingress_v1" "loki" {
#  metadata {
#    name      = "loki"
#    namespace = kubernetes_namespace_v1.loki.metadata[0].name
#    annotations = {
#      "kubernetes.io/ingress.class"                = "nginx"
#      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#      "ingress.kubernetes.io/rewrite-target"       = "/"
#      "nginx.ingress.kubernetes.io/upstream-vhost" = local.loki_upstream
#    }
#  }
#
#  spec {
#    rule {
#      host = "loki.dt.codehound.cz"
#      http {
#        path {
#          path      = "/"
#          path_type = "Prefix"
#          backend {
#            service {
#              name = kubernetes_service_v1.loki.metadata[0].name
#              port {
#                number = 80
#              }
#            }
#          }
#        }
#      }
#    }
#  }
#}