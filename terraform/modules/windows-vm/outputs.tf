output "vm_name" {
  description = "Resolved Windows VM name for downstream composition."
  value       = terraform_data.windows_vm.output.name
}

output "vm_spec" {
  description = "Normalized Windows VM specification consumed by provider-specific stacks."
  value       = terraform_data.windows_vm.output
}

output "base_image_id" {
  description = "Windows base image artifact ID passed from Packer outputs/manifests."
  value       = terraform_data.windows_vm.output.base_image.image_id
}

output "initialization" {
  description = "First-boot initialization contract for WinRM and administrator access enablement."
  value       = terraform_data.windows_vm.output.initialization
  sensitive   = true
}
