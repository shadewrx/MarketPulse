locals {
  prefix = "market-pulse"
}

resource "google_service_account" "market_pulse_node" {
  account_id   = "${local.prefix}-node"
  display_name = "Market Pulse Node"
}

resource "google_compute_instance" "market_pulse_vm" {
  for_each       = var.market_pulse_vms
  name           = "${local.prefix}-${each.key}-vm"
  machine_type   = each.value.machine_type
  can_ip_forward = true
  zone           = var.zone
  tags           = each.value.tags
  network_interface {
    subnetwork = google_compute_subnetwork.market_pulse_subnetwork.id
    network_ip = each.value.ip
  }
  boot_disk {
    initialize_params {
      image = var.image
      size  = 30
    }
  }
  service_account {
    email  = google_service_account.market_pulse_node.email
    scopes = ["cloud-platform"]
  }
}

