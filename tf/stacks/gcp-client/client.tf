locals {
  region = "europe-west1"
}

data "google_compute_zones" "available" {
  region = local.region
  status = "UP"
}

resource "google_compute_instance" "client" {
  count        = var.client_count
  machine_type = "e2-micro"
  name         = "${var.environment}-client-${count.index}"
  hostname     = "${var.environment}-gcp-client-${count.index}.${var.domain}"

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  boot_disk {
    auto_delete = true
    device_name = "root"

    initialize_params {
      #      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20231030"
      image = "nomad-client-20231205163324"
      size  = 32
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    subnetwork = var.subnet
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.admin_key.public_key_openssh}"
  }

  tags = ["client", "private"]
}