resource "kubernetes_namespace" "storage_nfs" {
  metadata {
    name = "storage-nfs"
  }
}

resource "helm_release" "nfs_storage" {
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart      = "nfs-subdir-external-provisioner"
  name       = "nfs-provisioner"
  namespace  = kubernetes_namespace.storage_nfs.metadata[0].name

  set {
    name  = "nfs.server"
    value = var.nfs_server
  }

  set {
    name  = "nfs.path"
    value = var.nfs_path
  }

  set {
    name  = "storageClass.defaultClass"
    value = "true"
  }
}