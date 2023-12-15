provider "helm" {
  kubernetes {
    config_path = "../../keys/demo-kubeconfig"
  }
}

provider "kubernetes" {
  config_path = "../../keys/demo-kubeconfig"
}

terraform {
  backend "local" {
    path = "../../tf-state/demo-control-plane.tfstate"
  }
}