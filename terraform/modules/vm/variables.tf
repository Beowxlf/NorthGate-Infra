variable "vm_name" {
  description = "Environment-scoped VM name."
  type        = string
}

variable "storage_pool" {
  description = "libvirt storage pool name used for VM disks and cloud-init seed images."
  type        = string
}

variable "cpu_count" {
  description = "Number of virtual CPUs assigned to the VM."
  type        = number
}

variable "memory_mb" {
  description = "Memory size in MB assigned to the VM."
  type        = number
}

variable "disk" {
  description = "Primary VM disk definition."
  type = object({
    size_gb = number
    type    = string
  })
}

variable "network_interface" {
  description = "Primary network interface definition for the VM."
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
  description = "Packer-produced base image identifier or artifact reference."
  type = object({
    image_id      = string
    image_version = optional(string)
    image_source  = optional(string)
  })
}

variable "admin_username" {
  description = "Linux bootstrap administrative username."
  type        = string
  default     = "ngadmin"
}

variable "ssh_authorized_keys" {
  description = "SSH public keys injected into the bootstrap admin account."
  type        = list(string)
  default     = []
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
