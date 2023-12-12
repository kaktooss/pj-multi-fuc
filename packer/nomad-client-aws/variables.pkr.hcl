variable "launch_block_size" {
  type    = number
  default = 20
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "amd64_instance_type" {
  type    = string
  default = ""
}
variable "arm64_instance_type" {
  type    = string
  default = ""
}

variable "arm64_aws_source_ami_owner" {
  type    = string
  default = ""
}
variable "amd64_aws_source_ami_owner" {
  type    = string
  default = ""
}

variable "amd64_aws_source_ami" {
  type    = string
  default = ""
}
variable "arm64_aws_source_ami" {
  type    = string
  default = ""
}

variable "arm64_aws_ssh_username" {
  type    = string
  default = ""
}
variable "amd64_aws_ssh_username" {
  type    = string
  default = ""
}
variable "subnet_name" {}