# VM Module (`terraform/modules/vm`)

## Purpose
Reusable, environment-agnostic VM definition module for NorthGate infrastructure stacks.

This module intentionally defines a deterministic VM contract (name, compute, storage, network, and image) without embedding provider-specific provisioning behavior or post-provision configuration logic.

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `vm_name` | `string` | yes | Environment-scoped VM name. |
| `cpu_count` | `number` | yes | Number of virtual CPUs. |
| `memory_mb` | `number` | yes | VM memory size in MB. |
| `disk` | `object({ size_gb = number, type = string })` | yes | Primary disk capacity and type profile. |
| `network_interface` | `object({ network_id = string, adapter_type = optional(string), ip_address = optional(string) })` | yes | Primary network interface contract. |
| `base_image` | `object({ image_id = string, image_version = optional(string), image_source = optional(string) })` | yes | Packer-built image reference. |
| `tags` | `map(string)` | no | Optional metadata labels. |

## Outputs

| Name | Description |
|---|---|
| `vm_name` | Resolved VM name for composition in environment roots. |
| `vm_spec` | Normalized VM specification object. |
| `base_image_id` | Packer image artifact identifier. |

## Packer Integration
- Pass image metadata from your Packer pipeline outputs/manifests into `base_image`.
- `base_image.image_id` is mandatory and should be treated as immutable build output.
- This module does not build images and does not mutate image contents.

## Scope Guardrails
- Terraform provisioning contract only.
- No configuration management logic.
- No application deployment logic.
