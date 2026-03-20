variable "org_slug" {
  description = "Short organization or platform identifier used for deterministic naming."
  type        = string
  default     = "northgate"
}

variable "environment_name" {
  description = "Environment identifier aligned to docs/01-architecture/environment-model.md (test-core)."
  type        = string
  default     = "test-core"

  validation {
    condition     = var.environment_name == "test-core"
    error_message = "Phase 1 stack only supports the test-core environment."
  }
}

variable "phase_name" {
  description = "Delivery phase identifier for naming/version partitioning."
  type        = string
  default     = "phase1"
}

variable "primary_zone" {
  description = "Primary logical zone for this root stack as defined in the dependency and trust-boundary model."
  type        = string
  default     = "core-services"
}

variable "hypervisor_uri" {
  description = "Hypervisor connection URI for libvirt provider (for example qemu+ssh://user@host/system)."
  type        = string
}

variable "network_cidrs" {
  description = "Environment-scoped CIDR definitions keyed by logical zone name."
  type        = map(string)
  default     = {}
}

variable "dns_domain" {
  description = "Internal DNS domain used for core service discovery."
  type        = string
  default     = "lab.internal"
}

variable "extra_tags" {
  description = "Optional additional tags/labels merged into common environment metadata."
  type        = map(string)
  default     = {}
}
