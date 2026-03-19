# Storage

## Storage Objectives
- Support deterministic provisioning of service data volumes.
- Separate OS/system disks from service data where possible.
- Ensure backup and restore alignment with recovery workflow.

## Storage Classes
- **Boot/System:** image-derived OS disk.
- **Service Data:** persistent storage for AD, Wazuh index/state, Prometheus TSDB, Grafana data, and application DB.
- **Artifact/Backup:** controlled retention location for backups and export artifacts.

## Ownership Model
- Terraform/OpenTofu provisions volume resources and attachments.
- Ansible formats/mounts volumes and configures service data paths.
- Operations runbooks define retention, rotation, and restore usage.

## Naming Convention
`ng-<env>-vol-<service-role>-<index>`

Examples:
- `ng-test-core-vol-wazuh-01`
- `ng-app-hosting-vol-db-01`

## Recovery Requirements
- Backup policy must cover identity, telemetry, and application data.
- Restore order must match service dependency chain.
