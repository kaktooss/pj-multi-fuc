provider "google" {
  credentials = "../../keys/dt-dev-gcp.json"
  project     = var.gcp_project_id
  region      = local.region
}

provider "helm" {
  kubernetes {
    config_path = "/keybase/private/kaktooss/k8s/pj-srv-0"
  }
}

provider "kubernetes" {
  config_path = "/keybase/private/kaktooss/k8s/pj-srv-0"
}

provider "tls" {}

provider "kubectl" {
  config_path = "/keybase/private/kaktooss/k8s/pj-srv-0"
}

terraform {
  backend "local" {
    path = "../../tf-state/pj-multi-fuc-gcp-client.tfstate"
  }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}