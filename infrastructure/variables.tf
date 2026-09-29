variable "project_id" {
  type    = string
  default = "market-pulse-507720"
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "zone" {
  type    = string
  default = "europe-central2-a"
}

variable "image" {
  type    = string
  default = "rocky-linux-cloud/rocky-linux-10"
}

variable "market_pulse_vms" {
  type = map(object({
    tags         = list(string)
    machine_type = string
    ip           = string
  }))
  default = {
    control-plane = {
      tags         = ["marketpulse-ssh", "marketpulse-node", "marketpulse-control-plane"]
      machine_type = "e2-medium"
      ip           = "10.10.0.10"
    }
    worker-1 = {
      tags         = ["marketpulse-ssh", "marketpulse-node", "marketpulse-worker"]
      machine_type = "e2-standard-2"
      ip           = "10.10.0.11"
    }
    worker-2 = {
      tags         = ["marketpulse-ssh", "marketpulse-node", "marketpulse-worker"]
      machine_type = "e2-standard-2"
      ip           = "10.10.0.12"
    }
  }
}