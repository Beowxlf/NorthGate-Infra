terraform {
  required_version = ">= 1.5.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

resource "libvirt_pool" "test_core" {
  name = var.storage_pool_name
  type = "dir"
  path = var.storage_pool_path
}

resource "libvirt_network" "test_core" {
  name      = var.network_name
  mode      = "nat"
  domain    = var.network_domain
  addresses = [var.network_cidr]
  autostart = true

  dns {
    enabled    = true
    local_only = true
  }
}

module "linux_control_vm" {
  source = "../../modules/vm"

  vm_name      = var.linux_control_vm.name
  storage_pool = libvirt_pool.test_core.name
  cpu_count    = var.linux_control_vm.cpu_count
  memory_mb    = var.linux_control_vm.memory_mb
  admin_username      = var.linux_control_vm.admin_username
  ssh_authorized_keys = var.linux_control_vm.ssh_authorized_keys

  disk = {
    size_gb = var.linux_control_vm.disk_size_gb
    type    = var.linux_control_vm.disk_type
  }

  network_interface = {
    network_id     = libvirt_network.test_core.name
    interface_name = var.linux_control_vm.interface_name
    ip_address     = var.linux_control_vm.ip_address
    cidr_prefix    = var.network_prefix_length
    gateway        = var.network_gateway
    dns_servers    = var.network_dns_servers
  }

  base_image = {
    image_id      = var.linux_control_vm.base_image_id
    image_version = var.linux_control_vm.base_image_version
    image_source  = var.linux_control_vm.base_image_source
  }

  tags = {
    environment = "production"
    service     = "control-plane"
    role        = "ansible-control"
  }
}

module "wazuh_vm" {
  source = "../../modules/vm"

  vm_name      = var.wazuh_vm.name
  storage_pool = libvirt_pool.test_core.name
  cpu_count    = var.wazuh_vm.cpu_count
  memory_mb    = var.wazuh_vm.memory_mb
  admin_username      = var.wazuh_vm.admin_username
  ssh_authorized_keys = var.wazuh_vm.ssh_authorized_keys

  disk = {
    size_gb = var.wazuh_vm.disk_size_gb
    type    = var.wazuh_vm.disk_type
  }

  network_interface = {
    network_id     = libvirt_network.test_core.name
    interface_name = var.wazuh_vm.interface_name
    ip_address     = var.wazuh_vm.ip_address
    cidr_prefix    = var.network_prefix_length
    gateway        = var.network_gateway
    dns_servers    = var.network_dns_servers
  }

  base_image = {
    image_id      = var.wazuh_vm.base_image_id
    image_version = var.wazuh_vm.base_image_version
    image_source  = var.wazuh_vm.base_image_source
  }

  tags = {
    environment = "production"
    service     = "wazuh"
    role        = "wazuh-manager"
  }
}

module "domain_controller_vm" {
  source = "../../modules/windows-vm"

  vm_name      = var.domain_controller_vm.name
  storage_pool = libvirt_pool.test_core.name
  cpu_count    = var.domain_controller_vm.cpu_count
  memory_mb    = var.domain_controller_vm.memory_mb

  disk = {
    size_gb = var.domain_controller_vm.disk_size_gb
    type    = var.domain_controller_vm.disk_type
  }

  network_interface = {
    network_id     = libvirt_network.test_core.name
    interface_name = var.domain_controller_vm.interface_name
    ip_address     = var.domain_controller_vm.ip_address
    cidr_prefix    = var.network_prefix_length
    gateway        = var.network_gateway
    dns_servers    = var.network_dns_servers
  }

  base_image = {
    image_id      = var.domain_controller_vm.base_image_id
    image_version = var.domain_controller_vm.base_image_version
    image_source  = var.domain_controller_vm.base_image_source
  }

  winrm = var.domain_controller_vm.winrm
  administrator_access = var.domain_controller_vm.administrator_access

  tags = {
    environment = "production"
    service     = "directory-services"
    role        = "domain-controller"
  }
}
