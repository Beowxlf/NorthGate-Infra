locals {
  # Integration contract for configuration management systems.
  # This block is data-only and intentionally performs no configuration actions.
  ansible_hosts = {
    (module.domain_controller_vm.vm_name) = {
      ansible_host = module.domain_controller_vm.vm_spec.network_interface.ip_address
      hostname     = module.domain_controller_vm.vm_name
      groups       = ["test_core", "domain_controllers"]
      metadata = {
        environment = "test-core"
        service     = "domain-controller"
      }
    }
  }

  ansible_inventory = {
    all = {
      children = {
        test_core = {
          hosts = {
            for host, hostvars in local.ansible_hosts :
            host => {
              ansible_host = hostvars.ansible_host
              hostname     = hostvars.hostname
              environment  = hostvars.metadata.environment
              service      = hostvars.metadata.service
            }
          }
          vars = {
            environment = "test-core"
          }
        }
        domain_controllers = {
          hosts = {
            for host, hostvars in local.ansible_hosts :
            host => {
              ansible_host = hostvars.ansible_host
              hostname     = hostvars.hostname
            }
            if contains(hostvars.groups, "domain_controllers")
          }
        }
      }
    }
  }
}

output "integration_vm_hostnames" {
  description = "Hostnames exported for downstream Ansible inventory generation."
  value       = keys(local.ansible_hosts)
}

output "integration_vm_ips" {
  description = "VM IP addresses exported for downstream Ansible inventory generation."
  value       = {
    for host, hostvars in local.ansible_hosts :
    host => hostvars.ansible_host
  }
}

output "ansible_inventory_data" {
  description = "Inventory-compatible map data consumed by Ansible dynamic/static inventory workflows."
  value       = local.ansible_inventory
}

output "ansible_inventory_yaml" {
  description = "YAML-encoded inventory-compatible data for file-based Ansible inventory generation."
  value       = yamlencode(local.ansible_inventory)
}

# Example Ansible inventory usage:
# 1) Generate inventory YAML from Terraform output:
#    terraform output -raw ansible_inventory_yaml > inventory.generated.yml
#
# 2) Validate generated inventory:
#    ansible-inventory -i inventory.generated.yml --graph
#
# 3) Run a playbook against test-core hosts:
#    ansible-playbook -i inventory.generated.yml ansible/playbooks/test-core.yml
#
# Integration flow:
# 1) Terraform provisions infrastructure and emits deterministic outputs (hostname, IP, inventory map).
# 2) Inventory output is exported as YAML/structured data.
# 3) Ansible consumes exported inventory for configuration steps in the Ansible layer.
# 4) No host configuration is performed in Terraform.
