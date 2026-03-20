variable "vm_name" {
  description = "Environment-scoped VM name."
  type        = string

  validation {
    condition     = length(trimspace(var.vm_name)) > 0
    error_message = "vm_name must not be empty."
  }
}

variable "cpu_count" {
  description = "Number of virtual CPUs assigned to the VM."
  type        = number

  validation {
    condition     = var.cpu_count >= 1
    error_message = "cpu_count must be at least 1."
  }
}

variable "memory_mb" {
  description = "Memory size in MB assigned to the VM."
  type        = number

  validation {
    condition     = var.memory_mb >= 512
    error_message = "memory_mb must be at least 512 MB."
  }
}

variable "disk" {
  description = "Primary VM disk definition."
  type = object({
    size_gb = number
    type    = string
  })

  validation {
    condition     = var.disk.size_gb >= 8
    error_message = "disk.size_gb must be at least 8 GB."
  }

  validation {
    condition     = length(trimspace(var.disk.type)) > 0
    error_message = "disk.type must not be empty."
  }
}

variable "network_interface" {
  description = "Primary network interface definition for the VM."
  type = object({
    network_id   = string
    adapter_type = optional(string)
    ip_address   = optional(string)
  })

  validation {
    condition     = length(trimspace(var.network_interface.network_id)) > 0
    error_message = "network_interface.network_id must not be empty."
  }
}

variable "base_image" {
  description = "Packer-produced base image identifier or artifact reference."
  type = object({
    image_id      = string
    image_version = optional(string)
    image_source  = optional(string)
  })

  validation {
    condition     = length(trimspace(var.base_image.image_id)) > 0
    error_message = "base_image.image_id must not be empty."
  }
}

variable "tags" {
  description = "Optional metadata tags for environment and ownership tracking."
  type        = map(string)
  default     = {}
}
