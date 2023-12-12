variable "aws_profile" {}
variable "aws_role" {}
variable "aws_region" {
  default = "eu-west-1"
}

variable "vpc_id" {
  type = string
}

variable "client_subnets" {
  type = list(string)
}

variable "client_count" {
  default = 0
}

variable "environment" {
  type        = string
  description = "Deployment environment used in tagging & naming. eg. dev, testing, prod"
}
