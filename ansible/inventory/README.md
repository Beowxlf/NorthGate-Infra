# Phase 1 Inventory Model (`test-core`)

## Scope
This directory defines the Phase 1 inventory and execution model for the `test-core` environment.

- Environment alignment: `docs/01-architecture/environment-model.md`
- Service alignment: `docs/02-infrastructure/service-catalog.md`
- Environment detail: `docs/04-environments/test-core.md`

## Structure

```text
ansible/inventory/
└── test-core/
    ├── hosts.yml
    ├── group_vars/
    │   ├── all.yml
    │   ├── os_linux.yml
    │   ├── os_windows.yml
    │   ├── control_plane.yml
    │   ├── directory_services.yml
    │   ├── time_services.yml
    │   ├── log_pipeline.yml
    │   └── wazuh_manager.yml
    └── host_vars/
        ├── tc-mgmt-ansible-01.yml
        ├── tc-mgmt-bastion-01.yml
        ├── tc-core-dc-01.yml
        ├── tc-core-dc-02.yml
        ├── tc-mon-log-01.yml
        └── tc-sec-wazuh-01.yml
```

## Grouping Strategy

Grouping is deterministic and multi-dimensional:

1. **Environment group** (`env_test_core`)
   - Enforces environment-scoped execution boundary.
2. **Zone groups** (`zone_management`, `zone_core_services`, `zone_monitoring_security`)
   - Maps directly to trust boundaries in the architecture model.
3. **Service groups** (`control_plane`, `directory_services`, `time_services`, `log_pipeline`, `wazuh_manager`)
   - Maps to Phase 1 services in the service catalog.
4. **Phase group** (`phase_1_test_core`)
   - Provides a single execution target for current implementation phase.
5. **OS groups** (`os_linux`, `os_windows`)
   - Enforces protocol and privilege model separation (SSH/Sudo vs WinRM/Kerberos).

## Control Node Usage

- Primary Ansible control node host: `tc-mgmt-ansible-01`.
- Inventory declares this node through `ng_control_node` in `group_vars/all.yml`.
- Execution model assumes operator runs playbooks from the control node (or CI runner that has equivalent network path and credentials).
- Hosts with `ng_access_path: via-bastion` are reachable only through managed jump-path policy.

## Connection Method

- Linux targets use SSH (`ansible_connection: ssh`, port `22`, `become: true`).
- Windows targets use WinRM over TLS (`ansible_connection: winrm`, port `5986`) with Kerberos transport.
- Host key / certificate validation is enabled by default (deterministic secure posture).

## Terraform/OpenTofu Output Integration

The inventory is designed for generated value injection from Terraform/OpenTofu outputs.

### Contract

`group_vars/all.yml` defines a stable contract:

- Artifact path: `ng_terraform_inventory_artifact`
- Required keys:
  - `hosts`
  - `ip_addresses`
  - `dns_names`
  - `access_paths`

### Integration Sequence

1. Terraform/OpenTofu apply completes for `test-core`.
2. Outputs are rendered into `terraform/out/test-core-ansible-inventory.json`.
3. Inventory generation step maps output keys to host_vars values (`ansible_host`, DNS aliases, and `ng_access_path`).
4. Ansible run executes against `phase_1_test_core` or individual service groups.

This keeps infrastructure addressing dynamic while preserving deterministic grouping and execution semantics.
