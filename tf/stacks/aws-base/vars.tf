variable "aws_profile" {}
variable "aws_role" {}
variable "aws_region" {
  default = "eu-west-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment used in tagging & naming. eg. dev, testing, prod"
}

variable "public_domain" {
  type        = string
  description = "Public domain name used for the platform"
}

variable "export_bastion_key_local" {
  default = false
}
variable "public_zone_id" {
  type        = string
  description = "Public zone id used for the platform"
}