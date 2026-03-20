terraform {
  required_version = ">= 1.5.0"
}

locals {
  vm_spec = {
    name              = var.vm_name
    cpu_count         = var.cpu_count
    memory_mb         = var.memory_mb
    disk              = var.disk
    network_interface = var.network_interface
    base_image        = var.base_image
    tags              = var.tags
  }
}

resource "terraform_data" "vm" {
  input = local.vm_spec
}
