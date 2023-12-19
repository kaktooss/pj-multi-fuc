variable "helm_max_history" {
  default = 5
}

variable "ingress_domain" {
  default = "192-168-1-21.nip.io"
}

variable "nomad_lb_ip" {
  default = "192.168.1.23"
}

variable "consul_addr" {
  default = "192-168-1-22.nip.io:8500"
}