provider "google" {
  credentials = "../../keys/dt-dev-gcp.json"
  project     = var.gcp_project_id
  region      = var.region
}

provider "helm" {
  kubernetes {
    config_path = "../../keys/pj-srv-0"
  }
}

provider "kubernetes" {
  config_path = "../../keys/pj-srv-0"
}

provider "tls" {}

provider "kubectl" {
  config_path = "../../keys/pj-srv-0"
}

terraform {
  backend "local" {
    path = "../../tf-state/pj-multi-fuc-base.tfstate"
  }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}