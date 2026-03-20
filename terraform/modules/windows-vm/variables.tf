variable "vm_name" {
  description = "Environment-scoped Windows VM name."
  type        = string
}

variable "storage_pool" {
  description = "libvirt storage pool name used for VM disks and cloud-init seed images."
  type        = string
}

variable "cpu_count" {
  description = "Number of virtual CPUs assigned to the Windows VM."
  type        = number
}

variable "memory_mb" {
  description = "Memory size in MB assigned to the Windows VM."
  type        = number
}

variable "disk" {
  description = "Primary Windows VM disk definition."
  type = object({
    size_gb = number
    type    = string
  })
}

variable "network_interface" {
  description = "Primary network interface definition for the Windows VM."
  type = object({
    network_id     = string
    interface_name = string
    ip_address     = string
    cidr_prefix    = number
    gateway        = string
    dns_servers    = list(string)
  })
}

variable "base_image" {
  description = "Packer-produced Windows base image libvirt volume id."
  type = object({
    image_id      = string
    image_version = optional(string)
    image_source  = optional(string)
  })
}

variable "winrm" {
  description = "Initial WinRM enablement contract for first-boot provisioning."
  type = object({
    transport = string
    port      = number
    use_tls   = bool
  })
  default = {
    transport = "https"
    port      = 5986
    use_tls   = true
  }
}

variable "administrator_access" {
  description = "Administrator account bootstrap contract for first access."
  type = object({
    username = string
    method   = string
    secret   = string
  })
}

variable "autostart" {
  description = "Whether VM autostarts with host hypervisor restart."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Optional metadata tags for environment and ownership tracking."
  type        = map(string)
  default     = {}
}
