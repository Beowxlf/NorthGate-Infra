terraform {
  required_version = ">= 1.6.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = var.hypervisor_uri
}

locals {
  environment = var.environment_name
  phase       = var.phase_name
  zone         = var.primary_zone

  name_prefix = lower(join("-", [var.org_slug, local.environment, local.phase]))

  common_tags = merge(
    {
      environment = local.environment
      phase       = local.phase
      zone        = local.zone
      managed_by  = "terraform"
      repository  = "NorthGate-Infra"
    },
    var.extra_tags
  )

  phase1_service_catalog = {
    core_services = [
      "active-directory",
      "internal-dns",
      "network-time"
    ]

    monitoring_security = [
      "central-log-pipeline",
      "wazuh-manager"
    ]
  }
}
