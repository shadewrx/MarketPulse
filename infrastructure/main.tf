resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "market_pulse_vpc" {
  name                    = "market-pulse"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.compute_api
  ]
}
resource "google_compute_subnetwork" "market_pulse_subnetwork" {
  name          = "market-pulse-vm-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.market_pulse_vpc.id
}

resource "google_compute_firewall" "market_pulse_firewall_ssh" {
  name        = "market-pulse-firewall-ssh"
  network     = google_compute_network.market_pulse_vpc.id
  description = "Allow SSH ingress to tagged MarketPulse VMs"
  direction   = "INGRESS"
  target_tags = ["marketpulse-ssh"]
  allow {
    protocol = "tcp"
    ports    = [22]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "market_pulse_firewall_node" {
  name        = "market-pulse-firewall-node"
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
  name    = "market-pulse-router"
  region  = google_compute_subnetwork.market_pulse_subnetwork.region
  network = google_compute_network.market_pulse_vpc.id
}

resource "google_compute_router_nat" "market_pulse_nat" {
  name                               = "market-pulse-nat"
  router                             = google_compute_router.market_pulse_router.name
  region                             = google_compute_router.market_pulse_router.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}

resource "google_service_account" "market_pulse_node" {
  account_id   = "market-pulse-node"
  display_name = "Market Pulse Node"
}

resource "google_compute_instance" "market_pulse_vm_control_plane" {
  name           = "market-pulse-plane-vm"
  machine_type   = "e2-medium"
  can_ip_forward = true
  zone           = var.zone
  tags           = ["marketpulse-ssh", "marketpulse-node", "marketpulse-control-plane"]
  network_interface {
    subnetwork = google_compute_subnetwork.market_pulse_subnetwork.id
    network_ip = "10.10.0.10"
  }
  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-10"
      size  = 30
    }
  }
  service_account {
    email  = google_service_account.market_pulse_node.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "market_pulse_vm_worker1" {
  name           = "market-pulse-worker1-vm"
  machine_type   = "e2-standard-2"
  can_ip_forward = true
  zone           = var.zone
  tags           = ["marketpulse-ssh", "marketpulse-node", "marketpulse-worker"]
  network_interface {
    subnetwork = google_compute_subnetwork.market_pulse_subnetwork.id
    network_ip = "10.10.0.11"
  }
  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-10"
      size  = 30
    }
  }
  service_account {
    email  = google_service_account.market_pulse_node.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "market_pulse_vm_worker2" {
  name           = "market-pulse-worker2-vm"
  machine_type   = "e2-standard-2"
  can_ip_forward = true
  zone           = var.zone
  tags           = ["marketpulse-ssh", "marketpulse-node", "marketpulse-worker"]
  network_interface {
    subnetwork = google_compute_subnetwork.market_pulse_subnetwork.id
    network_ip = "10.10.0.12"
  }
  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-10"
      size  = 30
    }
  }
  service_account {
    email  = google_service_account.market_pulse_node.email
    scopes = ["cloud-platform"]
  }
}

