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
    value = "192.168.1.8"
  }

  set {
    name  = "nfs.path"
    value = "/srv/nfs/micro-dt"
  }

  set {
    name  = "storageClass.defaultClass"
    value = "true"
  }
}