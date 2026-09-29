resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "market_pulse_vpc" {
  name                    = "${local.prefix}-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.compute_api
  ]
}
resource "google_compute_subnetwork" "market_pulse_subnetwork" {
  name          = "${local.prefix}-vm-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.market_pulse_vpc.id
}

resource "google_compute_firewall" "market_pulse_firewall_ssh" {
  name        = "${local.prefix}-firewall-ssh"
  network     = google_compute_network.market_pulse_vpc.id
  description = "Allow SSH ingress to tagged MarketPulse VMs"
  direction   = "INGRESS"
  target_tags = ["marketpulse-ssh"]
  allow {
    protocol = "tcp"
    ports    = [22]
  }
  #Ip range for IAP tunneling
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "market_pulse_firewall_node" {
  name        = "${local.prefix}-firewall-node"
  network     = google_compute_network.market_pulse_vpc.id
  description = "Allow communication between tagged MarketPulse node VMs"
  direction   = "INGRESS"
  target_tags = ["marketpulse-node"]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.market_pulse_subnetwork.ip_cidr_range]
}

resource "google_compute_router" "market_pulse_router" {
  name    = "${local.prefix}-router"
  region  = google_compute_subnetwork.market_pulse_subnetwork.region
  network = google_compute_network.market_pulse_vpc.id
}

resource "google_compute_router_nat" "market_pulse_nat" {
  name                               = "${local.prefix}-nat"
  router                             = google_compute_router.market_pulse_router.name
  region                             = google_compute_router.market_pulse_router.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}