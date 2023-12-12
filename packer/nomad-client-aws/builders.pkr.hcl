locals {
  time_formatted = "${formatdate("YYYY-MM-DD_hh-mm-ss", timestamp())}"
}

source "amazon-ebs" "amd64" {
  subnet_filter {
    filters = {
      "tag:Name": var.subnet_name
    }
    most_free = true
    random = false
  }

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = "${var.launch_block_size}"
    volume_type           = "gp2"
  }

  ami_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = "${var.launch_block_size}"
    volume_type           = "gp2"
  }

  region     = "${var.aws_region}"
  ami_name   = "nomad-client-${local.time_formatted}"
#  ami_groups = ["all"]

  source_ami    = "${var.amd64_aws_source_ami}"
  instance_type = "${var.amd64_instance_type}"
  ssh_username  = "${var.amd64_aws_ssh_username}"
  associate_public_ip_address = true

  force_deregister      = true
  force_delete_snapshot = true
}

build {
  sources = [
    "amazon-ebs.amd64",
  ]

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
