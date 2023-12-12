resource "kubernetes_namespace" "minio" {
  metadata {
    labels = {
      name = "minio"
    }

    name = "minio"
  }
}

resource "kubernetes_limit_range" "minio" {
  metadata {
    name      = "limit-range"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default = {
        memory = "1Gi"
      }

      default_request = {
        memory = "128M"
        cpu    = "100m"
      }
    }
  }
}

resource "kubernetes_persistent_volume_v1" "minio_nfs" {
  metadata {
    name = "minio-nfs-mount"
  }

  spec {
    mount_options = [
      "hard",
      "nfsvers=4.1",
    ]
    storage_class_name = "nfs-mount"
    access_modes       = ["ReadWriteMany"]
    capacity = {
      storage = "10Gi"
    }
    persistent_volume_source {
      nfs {
        path   = "/srv/nfs/minio"
        server = "192.168.1.8"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "minio_nfs" {
  depends_on = [kubernetes_persistent_volume_v1.minio_nfs]

  metadata {
    name      = "minio-nfs"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }

  spec {
    # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/567
    storage_class_name = "nfs-mount"
    access_modes       = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.minio_nfs.metadata[0].name
  }
}

locals {
  accessKey = "kaktooss"
}

resource "random_password" "minio_root" {
  special = false
  length  = 40
}

resource "helm_release" "minio" {
  depends_on = [kubernetes_persistent_volume_claim_v1.minio_nfs]

  namespace = kubernetes_namespace.minio.metadata[0].name

  repository = "https://charts.min.io/"
  name       = "minio"
  chart      = "minio"
  version    = "5.0.4"

  set_sensitive {
    name  = "rootUser"
    value = local.accessKey
  }

  set_sensitive {
    name  = "rootPassword"
    value = random_password.minio_root.result
  }

  values = [
    file("values/minio.yaml"),
  ]
}

output "root_key" {
  value = local.accessKey
}

output "root_secret" {
  sensitive = true
  value     = random_password.minio_root.result
}