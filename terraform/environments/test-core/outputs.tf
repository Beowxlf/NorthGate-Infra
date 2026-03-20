output "domain_controller_vm_name" {
  description = "VM name for the test-core foundational domain controller node."
  value       = module.domain_controller_vm.vm_name
}

output "domain_controller_vm_spec" {
  description = "Normalized VM specification for provider-specific environment composition."
  value       = module.domain_controller_vm.vm_spec
}
