# Storage Infrastructure

## Storage Types
- **root volumes:** OS disks for VM boot and system packages.
- **data volumes:** service and application data.
- **artifact storage:** image artifacts, logs, and deployment artifacts.

## Provisioning Ownership
Terraform/OpenTofu defines volume size, class, and attachment topology.
Ansible manages filesystem setup, mount configuration, and permissions.

## Naming Convention
Format: `ng-<env>-<role>-<purpose>-<index>`
- Example: `ng-workbench-app-data-01`.

## Persistence Policy
- `test-core`: ephemeral data allowed; restore from code preferred.
- `workbench`: selective persistence for active experiments.
- `app-hosting`: persistent volumes and scheduled backups required.

## Backup Requirements
- Snapshot schedule and retention are declared per environment.
- Restore test cadence: at least quarterly for persistent environments.
