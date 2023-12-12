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