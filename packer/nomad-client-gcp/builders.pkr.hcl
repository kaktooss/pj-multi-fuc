locals {
  time_formatted = "${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

source "googlecompute" "nomad-client" {
  project_id   = "codehound"
  source_image = "ubuntu-2204-jammy-v20231030"
  ssh_username = "ubuntu"
  disk_size    = 32
  zone         = "europe-west1-b"

  image_name = "nomad-client-${local.time_formatted}"
}

build {
  sources = ["sources.googlecompute.nomad-client"]

  provisioner "file" {
    source      = "config/nomad-common.hcl"
    destination = "/tmp/nomad-common.hcl"
  }

  provisioner "file" {
    source      = "config/nomad-client.hcl"
    destination = "/tmp/nomad-client.hcl"
  }

  provisioner "file" {
    source      = "config/nomad.service"
    destination = "/tmp/nomad.service"
  }

  provisioner "file" {
    source      = "../../bin/nomad"
    destination = "/tmp/nomad"
  }

  provisioner "file" {
    source      = "../../bin/nomad-driver-podman"
    destination = "/tmp/nomad-driver-podman"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/nomad",
      "sudo mkdir -p /etc/nomad.d",
      "sudo mkdir -p /usr/local/lib/nomad/plugins/",
      "sudo apt update && sudo apt install -y docker.io podman",
      "sudo mv /tmp/nomad /usr/local/bin/nomad",
      "sudo mv /tmp/nomad-driver-podman /usr/local/lib/nomad/plugins/nomad-driver-podman",
      "sudo mv /tmp/nomad-common.hcl /etc/nomad.d/nomad-common.hcl",
      "sudo mv /tmp/nomad-client.hcl /etc/nomad.d/nomad-client.hcl",
      "sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service",
      "sudo systemctl enable nomad",
    ]
  }
}
