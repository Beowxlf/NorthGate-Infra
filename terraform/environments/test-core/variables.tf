variable "vm_name" {
  description = "VM name for the test-core domain controller instance."
  type        = string
}

variable "cpu_count" {
  description = "vCPU count for the VM."
  type        = number
}

variable "memory_mb" {
  description = "Memory allocation in MB."
  type        = number
}

variable "disk_size_gb" {
  description = "Primary disk size in GB."
  type        = number
}

variable "disk_type" {
  description = "Disk profile/type label."
  type        = string
}

variable "network_id" {
  description = "Target network identifier for primary NIC."
  type        = string
}

variable "network_adapter_type" {
  description = "Optional adapter type for the primary NIC."
  type        = string
  default     = null
}

variable "ip_address" {
  description = "Optional static IP for primary NIC."
  type        = string
  default     = null
}

variable "base_image_id" {
  description = "Packer-built image artifact ID."
  type        = string
}

variable "base_image_version" {
  description = "Optional Packer image version metadata."
  type        = string
  default     = null
}

variable "base_image_source" {
  description = "Optional Packer manifest or registry source descriptor."
  type        = string
  default     = null
}
