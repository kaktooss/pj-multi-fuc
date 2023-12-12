resource "google_compute_instance" "router" {
  machine_type = "e2-micro"
  name         = "${var.environment}-router"
  hostname     = "rt.${var.domain}"

  zone = data.google_compute_zones.available.names[0]

  boot_disk {
    auto_delete = true
    device_name = "router-disk"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20231030"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward = true

  network_interface {
    access_config {
      network_tier = "PREMIUM"
      nat_ip       = google_compute_address.router.address
    }
    subnetwork = google_compute_subnetwork.eu_subnet.id
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.admin_key.public_key_openssh}"
  }

  tags = ["router", "public", "nat-gateway"]

  connection {
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "ubuntu"
    private_key = file("${path.module}/keys/${var.environment}-admin.key")
  }

  provisioner "file" {
    source      = "${path.module}/keys/wg0.conf"
    destination = "/tmp/wg0.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y wireguard",
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE",
      "sudo mv /tmp/wg0.conf /etc/wireguard/wg0.conf",
      "sudo systemctl enable wg-quick@wg0",
      "sudo systemctl start wg-quick@wg0",
    ]
  }
}

resource "google_compute_route" "nat" {
  count                  = 1
  name                   = "${var.environment}-eu-nat-${count.index}"
  network                = google_compute_network.vpc.id
  dest_range             = "0.0.0.0/0"
  tags                   = ["private"]
  next_hop_instance      = google_compute_instance.router.self_link
  next_hop_instance_zone = google_compute_instance.router.zone
  priority               = 500
  depends_on             = [google_compute_instance.router]
}

output "router_ip" {
  value = google_compute_instance.router.network_interface[0].access_config[0].nat_ip
}