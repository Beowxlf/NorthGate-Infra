output "vm_name" {
  description = "Resolved VM name for downstream composition."
  value       = libvirt_domain.vm.name
}

output "hostname" {
  description = "Hostname assigned to the VM."
  value       = local.vm_hostname
}

output "ip_address" {
  description = "Deterministic static IP assigned to the VM primary NIC."
  value       = var.network_interface.ip_address
}

output "vm_spec" {
  description = "Normalized VM specification consumed by environment integration outputs."
  value       = local.vm_spec
}

output "base_image_id" {
  description = "Base image artifact ID passed from Packer outputs/manifests."
  value       = var.base_image.image_id
}
