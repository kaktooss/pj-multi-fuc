data "aws_caller_identity" "current" {}

locals {
  tags = {
    "Environment" = var.environment
  }
}
