variable "helm_max_history" {
  default = 5
}

variable "domain_name" {
  default = "dt.codehound.cz"
}

variable "nomad_lb_ip" {
  default = "192.168.1.23"
}

variable "consul_addr" {
  default = "192.168.1.22:8500"
}