# Windows VM Module (`terraform/modules/windows-vm`)

## Purpose
Reusable, environment-agnostic Windows VM definition module for NorthGate infrastructure stacks.

This module follows the same pattern as `terraform/modules/vm` and defines a deterministic provisioning contract only: compute, storage, network, image, and first-boot bootstrap inputs for WinRM and administrator access.

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `vm_name` | `string` | yes | Environment-scoped Windows VM name. |
| `cpu_count` | `number` | yes | Number of virtual CPUs. |
| `memory_mb` | `number` | yes | VM memory size in MB. |
| `disk` | `object({ size_gb = number, type = string })` | yes | Primary disk capacity and type profile. |
| `network_interface` | `object({ network_id = string, adapter_type = optional(string), ip_address = optional(string) })` | yes | Primary network interface contract. |
| `base_image` | `object({ image_id = string, image_version = optional(string), image_source = optional(string) })` | yes | Packer-built Windows image reference. |
| `winrm` | `object({ transport = string, port = number, use_tls = bool })` | no | Initial WinRM bootstrap defaults to HTTPS/5986/TLS enabled. |
| `administrator_access` | `object({ username = string, method = string, secret = string })` | yes | Administrator bootstrap access contract for first login. |
| `tags` | `map(string)` | no | Optional metadata labels. |

## Outputs

| Name | Description |
|---|---|
| `vm_name` | Resolved VM name for composition in environment roots. |
| `vm_spec` | Normalized Windows VM specification object. |
| `base_image_id` | Packer image artifact identifier. |
| `initialization` | First-boot initialization contract for WinRM and administrator setup (sensitive). |

## Example Usage (Domain Controller VM Class)

```hcl
module "domain_controller_windows_vm" {
  source = "../../modules/windows-vm"

  vm_name   = "test-core-dc01"
  cpu_count = 4
  memory_mb = 8192

  disk = {
    size_gb = 120
    type    = "ssd"
  }

  network_interface = {
    network_id   = "test-core-server-net"
    adapter_type = "vmxnet3"
    ip_address   = "10.40.10.20"
  }

  base_image = {
    image_id      = "windows-server-2022-golden-2026.03.01"
    image_version = "2026.03.01"
    image_source  = "packer/windows-server-2022"
  }

  winrm = {
    transport = "https"
    port      = 5986
    use_tls   = true
  }

  administrator_access = {
    username = "lab-admin"
    method   = "secret_ref"
    secret   = "secret://test-core/domain-controller/lab-admin"
  }

  tags = {
    environment = "test-core"
    service     = "domain-controller"
    os_family   = "windows"
  }
}
```

## Provisioning vs Configuration Boundary

### Terraform Provisioning Scope (this module)
1. Declares deterministic Windows VM infrastructure contract.
2. Defines first-boot WinRM enablement inputs for remote management bootstrap.
3. Defines administrator bootstrap access inputs for initial privileged access.
4. Produces normalized outputs for downstream provider-specific composition.

### Explicitly Out of Scope (handled elsewhere)
1. Active Directory role installation/promotion.
2. Domain forest/domain join operations.
3. Application or agent software installation.
4. Ongoing OS hardening, patching, and service configuration.

Use Ansible roles/playbooks for post-provision Windows configuration and service lifecycle tasks.
