data "aws_caller_identity" "current" {}

locals {
  #  client_ami         = "ami-0a3a484e07ffb6be7" # Vanilla ubuntu
  client_ami         = "ami-0098cf8b60fdf6e13" # Packer image
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}
