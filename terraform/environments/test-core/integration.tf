locals {
  hosts = {
    (module.linux_control_vm.hostname) = {
      ansible_host = module.linux_control_vm.ip_address
      hostname     = module.linux_control_vm.hostname
      groups       = ["env_test_core", "control_plane", "os_linux", "phase_1_test_core"]
      metadata = {
        role        = "ansible-control"
        environment = "test-core"
        service     = "control-plane"
      }
    }

    (module.wazuh_vm.hostname) = {
      ansible_host = module.wazuh_vm.ip_address
      hostname     = module.wazuh_vm.hostname
      groups       = ["env_test_core", "wazuh_manager", "os_linux", "phase_1_test_core", "zone_monitoring_security"]
      metadata = {
        role        = "wazuh-manager"
        environment = "test-core"
        service     = "wazuh"
      }
    }

    (module.domain_controller_vm.hostname) = {
      ansible_host = module.domain_controller_vm.ip_address
      hostname     = module.domain_controller_vm.hostname
      groups       = ["env_test_core", "directory_services", "time_services", "os_windows", "phase_1_test_core", "zone_core_services"]
      metadata = {
        role        = "domain-controller"
        environment = "test-core"
        service     = "directory-services"
      }
    }
  }

  ansible_inventory = {
    all = {
      children = {
        env_test_core = {
          hosts = {
            for host, hostvars in local.hosts :
            host => {
              ansible_host = hostvars.ansible_host
              hostname     = hostvars.hostname
              ng_environment = hostvars.metadata.environment
              ng_role      = hostvars.metadata.role
            }
          }
        }

        control_plane = {
          hosts = {
            for host, hostvars in local.hosts : host => {}
            if contains(hostvars.groups, "control_plane")
          }
        }

        directory_services = {
          hosts = {
            for host, hostvars in local.hosts : host => {}
            if contains(hostvars.groups, "directory_services")
          }
        }

        time_services = {
          hosts = {
            for host, hostvars in local.hosts : host => {}
            if contains(hostvars.groups, "time_services")
          }
        }

        wazuh_manager = {
          hosts = {
            for host, hostvars in local.hosts : host => {}
            if contains(hostvars.groups, "wazuh_manager")
          }
        }

        os_linux = {
          hosts = {
            for host, hostvars in local.hosts : host => {}
            if contains(hostvars.groups, "os_linux")
          }
        }

        os_windows = {
          hosts = {
            for host, hostvars in local.hosts : host => {}
            if contains(hostvars.groups, "os_windows")
          }
        }

        phase_1_test_core = {
          children = {
            control_plane     = {}
            directory_services = {}
            time_services     = {}
            wazuh_manager     = {}
          }
        }
      }
    }
  }
}

output "integration_vm_hostnames" {
  description = "Hostnames exported for downstream Ansible inventory generation."
  value       = keys(local.hosts)
}

output "integration_vm_ips" {
  description = "VM IP addresses exported for downstream Ansible inventory generation."
  value       = { for host, hostvars in local.hosts : host => hostvars.ansible_host }
}

output "integration_role_mapping" {
  description = "Role mapping exported for downstream orchestration checks."
  value       = { for host, hostvars in local.hosts : host => hostvars.metadata.role }
}

output "ansible_inventory_data" {
  description = "Inventory-compatible map data consumed by Ansible dynamic/static inventory workflows."
  value       = local.ansible_inventory
}

output "ansible_inventory_yaml" {
  description = "YAML-encoded inventory-compatible data for file-based Ansible inventory generation."
  value       = yamlencode(local.ansible_inventory)
}

output "ansible_inventory_json" {
  description = "JSON-encoded inventory-compatible data for file-based Ansible inventory generation."
  value       = jsonencode(local.ansible_inventory)
}
