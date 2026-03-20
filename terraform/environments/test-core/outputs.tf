output "network_name" {
  description = "Provisioned libvirt network name for test-core environment."
  value       = libvirt_network.test_core.name
}

output "linux_control_vm" {
  description = "Provisioned Linux control node VM contract."
  value       = module.linux_control_vm.vm_spec
}

output "wazuh_vm" {
  description = "Provisioned Linux Wazuh manager VM contract."
  value       = module.wazuh_vm.vm_spec
}

output "domain_controller_vm" {
  description = "Provisioned Windows domain controller VM contract."
  value       = module.domain_controller_vm.vm_spec
}
