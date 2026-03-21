variable "libvirt_uri" {
  description = "libvirt connection URI."
  type        = string
  default     = "qemu:///system"
}

variable "storage_pool_name" {
  description = "Storage pool used for environment VM disks."
  type        = string
  default     = "production-pool"
}

variable "storage_pool_path" {
  description = "Directory path backing storage pool."
  type        = string
}

variable "network_name" {
  description = "libvirt network name for production environment."
  type        = string
  default     = "production-net"
}

variable "network_domain" {
  description = "DNS domain suffix associated with environment network."
  type        = string
  default     = "production.northgate.local"
}

variable "network_cidr" {
  description = "CIDR for the production network."
  type        = string
}

variable "network_gateway" {
  description = "Default gateway for production VM interfaces."
  type        = string
}

variable "network_prefix_length" {
  description = "CIDR prefix length for static VM interface assignments."
  type        = number
}

variable "network_dns_servers" {
  description = "Deterministic DNS server list used for all production VMs."
  type        = list(string)
}

variable "linux_control_vm" {
  description = "Linux VM definition for Ansible control-plane node."
  type = object({
    name                = string
    cpu_count           = number
    memory_mb           = number
    disk_size_gb        = number
    disk_type           = string
    interface_name      = string
    ip_address          = string
    admin_username      = string
    ssh_authorized_keys = list(string)
    base_image_id       = string
    base_image_version  = optional(string)
    base_image_source   = optional(string)
  })
}

variable "wazuh_vm" {
  description = "Linux VM definition for Wazuh manager node."
  type = object({
    name                = string
    cpu_count           = number
    memory_mb           = number
    disk_size_gb        = number
    disk_type           = string
    interface_name      = string
    ip_address          = string
    admin_username      = string
    ssh_authorized_keys = list(string)
    base_image_id       = string
    base_image_version  = optional(string)
    base_image_source   = optional(string)
  })
}

variable "domain_controller_vm" {
  description = "Windows VM definition for Domain Controller node."
  type = object({
    name               = string
    cpu_count          = number
    memory_mb          = number
    disk_size_gb       = number
    disk_type          = string
    interface_name     = string
    ip_address         = string
    base_image_id      = string
    base_image_version = optional(string)
    base_image_source  = optional(string)
    winrm = object({
      transport = string
      port      = number
      use_tls   = bool
    })
    administrator_access = object({
      username = string
      method   = string
      secret   = string
    })
  })
  sensitive = true
}
