# Terraform Variables
variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "codehound"
}

variable "region" {
  default = "us-east1"
}

variable "helm_max_history" {
  default = 5
}

variable "lb_address_pool" {
  default = ""
}

variable "nfs_server" {
  default = "192.168.1.8"
}

variable "nfs_path" {
  default = "/srv/nfs/micro-dt"
}

variable "ingress_ip" {
  default = ""
}