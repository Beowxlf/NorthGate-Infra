terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8"
    }
  }
}

locals {
  vm_hostname = lower(var.vm_name)

  user_data = templatefile("${path.module}/templates/linux-user-data.yaml.tftpl", {
    hostname            = local.vm_hostname
    admin_username      = var.admin_username
    ssh_authorized_keys = var.ssh_authorized_keys
  })

  network_config = templatefile("${path.module}/templates/linux-network-config.yaml.tftpl", {
    interface_name = var.network_interface.interface_name
    ip_address     = var.network_interface.ip_address
    cidr_prefix    = var.network_interface.cidr_prefix
    gateway        = var.network_interface.gateway
    dns_servers    = var.network_interface.dns_servers
  })

  vm_spec = {
    id                = libvirt_domain.vm.id
    hostname          = local.vm_hostname
    ip_address        = var.network_interface.ip_address
    cpu_count         = var.cpu_count
    memory_mb         = var.memory_mb
    disk              = var.disk
    network_interface = var.network_interface
    base_image        = var.base_image
    tags              = var.tags
  }
}

resource "libvirt_volume" "os_disk" {
  name           = "${local.vm_hostname}-os.qcow2"
  pool           = var.storage_pool
  base_volume_id = var.base_image.image_id
  size           = var.disk.size_gb * 1024 * 1024 * 1024
}

resource "libvirt_cloudinit_disk" "seed" {
  name           = "${local.vm_hostname}-seed.iso"
  pool           = var.storage_pool
  user_data      = local.user_data
  network_config = local.network_config
}

resource "libvirt_domain" "vm" {
  name      = local.vm_hostname
  vcpu      = var.cpu_count
  memory    = var.memory_mb
  qemu_agent = true
  autostart = var.autostart

  disk {
    volume_id = libvirt_volume.os_disk.id
  }

  network_interface {
    network_name   = var.network_interface.network_id
    hostname       = local.vm_hostname
    wait_for_lease = false
    addresses      = [var.network_interface.ip_address]
  }

  cloudinit = libvirt_cloudinit_disk.seed.id

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
    autoport    = true
  }
}
