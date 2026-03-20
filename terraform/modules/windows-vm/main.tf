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

  user_data = templatefile("${path.module}/templates/windows-user-data.ps1.tftpl", {
    admin_username = var.administrator_access.username
    admin_password = var.administrator_access.secret
    winrm_port     = var.winrm.port
    allow_http     = lower(var.winrm.transport) == "http"
    use_tls        = var.winrm.use_tls
  })

  network_config = templatefile("${path.module}/templates/windows-network-config.yaml.tftpl", {
    interface_name = var.network_interface.interface_name
    ip_address     = var.network_interface.ip_address
    cidr_prefix    = var.network_interface.cidr_prefix
    gateway        = var.network_interface.gateway
    dns_servers    = var.network_interface.dns_servers
  })

  initialization = {
    winrm = {
      transport = lower(var.winrm.transport)
      port      = var.winrm.port
      use_tls   = var.winrm.use_tls
    }
    administrator_access = {
      username = var.administrator_access.username
      method   = lower(var.administrator_access.method)
    }
  }

  windows_vm_spec = {
    id                = libvirt_domain.windows_vm.id
    os_family         = "windows"
    name              = local.vm_hostname
    hostname          = local.vm_hostname
    ip_address        = var.network_interface.ip_address
    cpu_count         = var.cpu_count
    memory_mb         = var.memory_mb
    disk              = var.disk
    network_interface = var.network_interface
    base_image        = var.base_image
    initialization    = local.initialization
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

resource "libvirt_domain" "windows_vm" {
  name       = local.vm_hostname
  vcpu       = var.cpu_count
  memory     = var.memory_mb
  autostart  = var.autostart
  qemu_agent = true

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

  tpm {
    backend_type = "emulator"
    version      = "2.0"
  }

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
