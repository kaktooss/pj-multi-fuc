provider "google" {
  credentials = "../../keys/dt-dev-gcp.json"
  project     = var.gcp_project_id
  region      = var.region
}

provider "helm" {
  kubernetes {
    config_path = "../../keys/demo-kubeconfig"
  }
}

provider "kubernetes" {
  config_path = "../../keys/demo-kubeconfig"
}

provider "tls" {}

provider "kubectl" {
  config_path = "../../keys/demo-kubeconfig"
}

terraform {
  backend "local" {
    path = "../../tf-state/demo-base.tfstate"
  }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}