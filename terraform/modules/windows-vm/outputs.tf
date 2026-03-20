output "vm_name" {
  description = "Resolved Windows VM name for downstream composition."
  value       = libvirt_domain.windows_vm.name
}

output "hostname" {
  description = "Hostname assigned to the Windows VM."
  value       = local.vm_hostname
}

output "ip_address" {
  description = "Deterministic static IP assigned to the Windows VM primary NIC."
  value       = var.network_interface.ip_address
}

output "vm_spec" {
  description = "Normalized Windows VM specification consumed by provider-specific stacks."
  value       = local.windows_vm_spec
}

output "base_image_id" {
  description = "Windows base image artifact ID passed from Packer outputs/manifests."
  value       = var.base_image.image_id
}

output "initialization" {
  description = "First-boot initialization contract for WinRM and administrator access enablement."
  value       = local.initialization
  sensitive   = true
}
