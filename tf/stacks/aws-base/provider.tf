provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  assume_role {
    role_arn     = var.aws_role
    session_name = "terraform"
  }
}

terraform {
  backend "local" {
    path = "../../tf-state/pj-multi-fuc-aws-base.tfstate"
  }
}