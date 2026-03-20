variable "vm_name" {
  description = "Environment-scoped Windows VM name."
  type        = string

  validation {
    condition     = length(trimspace(var.vm_name)) > 0
    error_message = "vm_name must not be empty."
  }
}

variable "cpu_count" {
  description = "Number of virtual CPUs assigned to the Windows VM."
  type        = number

  validation {
    condition     = var.cpu_count >= 1
    error_message = "cpu_count must be at least 1."
  }
}

variable "memory_mb" {
  description = "Memory size in MB assigned to the Windows VM."
  type        = number

  validation {
    condition     = var.memory_mb >= 1024
    error_message = "memory_mb must be at least 1024 MB for Windows workloads."
  }
}

variable "disk" {
  description = "Primary Windows VM disk definition."
  type = object({
    size_gb = number
    type    = string
  })

  validation {
    condition     = var.disk.size_gb >= 32
    error_message = "disk.size_gb must be at least 32 GB for Windows workloads."
  }

  validation {
    condition     = length(trimspace(var.disk.type)) > 0
    error_message = "disk.type must not be empty."
  }
}

variable "network_interface" {
  description = "Primary network interface definition for the Windows VM."
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
  description = "Packer-produced Windows base image identifier or artifact reference."
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

  validation {
    condition     = contains(["http", "https"], lower(var.winrm.transport))
    error_message = "winrm.transport must be either http or https."
  }

  validation {
    condition     = var.winrm.port >= 1 && var.winrm.port <= 65535
    error_message = "winrm.port must be between 1 and 65535."
  }
}

variable "administrator_access" {
  description = "Administrator account bootstrap contract for first access."
  type = object({
    username = string
    method   = string
    secret   = string
  })

  validation {
    condition     = length(trimspace(var.administrator_access.username)) > 0
    error_message = "administrator_access.username must not be empty."
  }

  validation {
    condition     = contains(["password", "keyvault_ref", "secret_ref"], lower(var.administrator_access.method))
    error_message = "administrator_access.method must be password, keyvault_ref, or secret_ref."
  }

  validation {
    condition     = length(trimspace(var.administrator_access.secret)) > 0
    error_message = "administrator_access.secret must not be empty."
  }
}

variable "tags" {
  description = "Optional metadata tags for environment and ownership tracking."
  type        = map(string)
  default     = {}
}
