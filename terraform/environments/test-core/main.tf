terraform {
  required_version = ">= 1.5.0"
}

module "domain_controller_vm" {
  source = "../../modules/vm"

  vm_name   = var.vm_name
  cpu_count = var.cpu_count
  memory_mb = var.memory_mb

  disk = {
    size_gb = var.disk_size_gb
    type    = var.disk_type
  }

  network_interface = {
    network_id   = var.network_id
    adapter_type = var.network_adapter_type
    ip_address   = var.ip_address
  }

  base_image = {
    image_id      = var.base_image_id
    image_version = var.base_image_version
    image_source  = var.base_image_source
  }

  tags = {
    environment = "test-core"
    service     = "domain-controller"
  }
}
