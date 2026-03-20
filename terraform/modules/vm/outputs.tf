output "vm_name" {
  description = "Resolved VM name for downstream composition."
  value       = terraform_data.vm.output.name
}

output "vm_spec" {
  description = "Normalized VM specification consumed by provider-specific stacks."
  value       = terraform_data.vm.output
}

output "base_image_id" {
  description = "Base image artifact ID passed from Packer outputs/manifests."
  value       = terraform_data.vm.output.base_image.image_id
}
