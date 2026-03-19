# Compute

## Compute Design Principles
- Compute nodes are role-specific and immutable-by-default at the image baseline.
- Image standardization is performed by Packer.
- Runtime configuration is applied through Ansible after provisioning.

## Node Naming Standard
`ng-<env>-<service-role>-<index>`

Examples:
- `ng-test-core-dc-01`
- `ng-workbench-control-01`
- `ng-app-hosting-app-01`

## Role-to-Environment Mapping
- `test-core`: `dc`, `wazuh`, `prometheus`, `grafana` roles.
- `workbench`: `jump`, `control`, `caldera`, `attack` roles.
- `app-hosting`: `proxy`, `app`, `db`, optional `worker` roles.

## Provisioning Ownership
Terraform/OpenTofu modules must define:
- CPU/memory/disk classes per role.
- NIC attachments by segment.
- Boot image reference and metadata outputs for Ansible inventory.

## Configuration Ownership
Ansible roles must define:
- Base OS hardening and account policy.
- Service package/runtime configuration.
- Health verification handlers and restart logic.
