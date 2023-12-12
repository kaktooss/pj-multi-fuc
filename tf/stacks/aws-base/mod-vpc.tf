data "aws_availability_zones" "available" {}

locals {
  region = "eu-west-1"

  vpc_cidr = "10.1.0.0/16"

  public_subnets  = ["10.1.64.0/18", "10.1.0.0/18"]
  private_subnets = ["10.1.128.0/18", "10.1.192.0/18"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = "${var.environment}-vpc"
  cidr = local.vpc_cidr

  azs = ["${var.aws_region}a", "${var.aws_region}b"]

  public_subnets      = local.public_subnets
  public_subnet_names = ["${var.environment}-pub-a", "${var.environment}-pub-b"]

  private_subnets      = local.private_subnets
  private_subnet_names = ["${var.environment}-prv-a", "${var.environment}-prv-b"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Type = "public"
  }

  private_subnet_tags = {
    Type = "private"
  }

  tags = local.tags
}

output "vpc_id" {
  value = module.vpc.vpc_id
}