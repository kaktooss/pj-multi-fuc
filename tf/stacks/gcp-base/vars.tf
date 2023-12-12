variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "codehound"
}

variable "environment" {
  type        = string
  description = "Deployment environment used in tagging & naming. eg. dev, testing, prod"
}

variable "domain" {
  default = "gcp.fuc.codehound.cz"
}
