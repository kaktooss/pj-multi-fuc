variable "nomad_instance_count" {
  default = 3
}

resource "kubernetes_namespace" "nomad" {
  metadata {
    name = "nomad"
  }
}

resource "kubernetes_config_map_v1" "nomad_config" {
  depends_on = [kubernetes_namespace.nomad]

  metadata {
    name      = "nomad-config"
    namespace = kubernetes_namespace.nomad.metadata[0].name
  }

  data = {
    "nomad-node.hcl.tpl" = templatefile("${path.module}/resources/nomad-node.hcl", {
      nomad_lb = var.nomad_lb_ip
    })
    "nomad-server.hcl" = templatefile("${path.module}/resources/nomad-server.hcl", {
      consul_addr = var.consul_addr
    })
  }
}

resource "kubernetes_stateful_set_v1" "nomad" {
  depends_on = [kubernetes_config_map_v1.nomad_config, kubernetes_service_v1.nomad_int]

  metadata {
    name      = "nomad"
    namespace = kubernetes_namespace.nomad.metadata[0].name
    labels = {
      app = "nomad"
    }
  }

  spec {
    service_name = "nomad"
    replicas     = var.nomad_instance_count
    selector {
      match_labels = {
        app = "nomad"
      }
    }

    template {
      metadata {
        labels = {
          app = "nomad"
        }
      }

      spec {
        volume {
          name = "nomad-config"

          config_map {
            name = "nomad-config"
            items {
              key  = "nomad-server.hcl"
              path = "nomad-server.hcl"
            }
            items {
              key  = "nomad-node.hcl.tpl"
              path = "nomad-node.hcl.tpl"
            }
          }
        }

        volume {
          name = "nomad-config-node"
          empty_dir {}
        }

        init_container {
          name  = "config"
          image = "busybox"

          command = [
            "/bin/sh",
            "-c",
            "eval \"echo \\\"`cat /etc/nomad.d/nomad-node.hcl.tpl`\\\"\" > /var/nomad/config/nomad-node.hcl && cat /var/nomad/config/nomad-node.hcl && cp /etc/nomad.d/nomad-server.hcl /var/nomad/config/nomad-server.hcl",
          ]

          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          volume_mount {
            name       = "nomad-config"
            mount_path = "/etc/nomad.d"
          }

          volume_mount {
            name       = "nomad-config-node"
            mount_path = "/var/nomad/config"
          }
        }

        container {
          name  = "nomad"
          image = "hashicorp/nomad:1.6.1"
          args = [
            "agent",
            "-server",
            "-config",
            "/etc/nomad.d",
            "-data-dir",
            "/var/nomad",
          ]

          env {
            name  = "NOMAD_SKIP_DOCKER_IMAGE_WARN"
            value = "true"
          }
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          env {
            name  = "NOMAD_ADDR"
            value = "http://$(POD_IP):4646"
          }

          volume_mount {
            name       = "nomad-config-node"
            mount_path = "/etc/nomad.d"
          }
          volume_mount {
            name       = "data-nomad"
            mount_path = "/var/nomad"
          }

          port {
            name           = "http"
            container_port = 4646
          }
          port {
            name           = "rpc"
            container_port = 4647
          }
          port {
            name           = "serf-tcp"
            container_port = 4648
            protocol       = "TCP"
          }
          port {
            name           = "serf-udp"
            container_port = 4648
            protocol       = "UDP"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data-nomad"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nomad_int" {
  count = var.nomad_instance_count
  metadata {
    name      = "nomad-${count.index}-int"
    namespace = kubernetes_namespace.nomad.metadata[0].name
  }

  spec {
    selector = {
      "statefulset.kubernetes.io/pod-name" = "nomad-${count.index}"
    }

    port {
      name        = "rpc"
      protocol    = "TCP"
      port        = 4647
      target_port = 4647
    }

    port {
      name        = "serf-tcp"
      protocol    = "TCP"
      port        = 4648
      target_port = 4648
    }

    port {
      name        = "serf-udp"
      protocol    = "UDP"
      port        = 4648
      target_port = 4648
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_v1" "nomad_lb" {
  depends_on = [kubernetes_stateful_set_v1.nomad]

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
    load_balancer_ip = var.nomad_lb_ip

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
              name = kubernetes_service_v1.nomad_lb.metadata[0].name
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