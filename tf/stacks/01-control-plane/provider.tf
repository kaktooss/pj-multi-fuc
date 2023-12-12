provider "helm" {
  kubernetes {
    config_path = "../../keys/pj-srv-0"
  }
}

provider "kubernetes" {
  config_path = "../../keys/pj-srv-0"
}

provider "kubectl" {
  config_path = "../../keys/pj-srv-0"
}

terraform {
  backend "local" {
    path = "../../tf-state/pj-multi-fuc-control-plane.tfstate"
  }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}