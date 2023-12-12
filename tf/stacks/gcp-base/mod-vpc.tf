locals {
  region          = "europe-west1"
  vpc_cidr        = "10.2.0.0/16"
  public_subnets  = ["10.2.64.0/18", "10.2.0.0/18"]
  private_subnets = ["10.2.128.0/18", "10.2.192.0/18"]
}

data "google_compute_zones" "available" {
  region = local.region
  status = "UP"
}

resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "eu_subnet" {
  name          = "${var.environment}-eu-subnet"
  ip_cidr_range = local.vpc_cidr
  region        = local.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true
}

resource "google_compute_address" "router" {
  region       = local.region
  name         = "${var.environment}-eu-router"
  address_type = "EXTERNAL"
}

resource "google_compute_firewall" "router" {
  name    = "${var.environment}-router"
  network = google_compute_network.vpc.id

  allow {
    protocol = "UDP"
    ports    = ["53145"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["router"]
}

resource "google_compute_firewall" "public_ingress" {
  name    = "${var.environment}-public-ingress"
  network = google_compute_network.vpc.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public"]
}

resource "google_compute_firewall" "nat_outbound" {
  name          = "${var.environment}-${local.region}-nat-outbound"
  network       = google_compute_network.vpc.id
  target_tags   = ["nat-gateway"]
  source_ranges = [local.vpc_cidr]
  source_tags   = ["nat-gateway"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "private_ingress" {
  name    = "${var.environment}-private-ingress"
  network = google_compute_network.vpc.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [local.vpc_cidr]
  target_tags   = ["private"]
}

resource "google_compute_route" "internet_gateway" {
  name             = "${var.environment}-igw-${local.region}"
  network          = google_compute_network.vpc.id
  dest_range       = "0.0.0.0/0"
  priority         = "300"
  next_hop_gateway = "default-internet-gateway"
  tags             = ["public"]
}

resource "google_compute_route" "client" {
  name              = "${var.environment}-client"
  network           = google_compute_network.vpc.id
  dest_range        = "192.168.1.0/24"
  tags              = ["client"]
  next_hop_instance = google_compute_instance.router.self_link
}

output "subnet_id" {
  value = google_compute_subnetwork.eu_subnet.id
}