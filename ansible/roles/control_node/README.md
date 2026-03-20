# control_node role

Baseline role for the control node (jump host) that executes infrastructure workflows.

## Responsibilities

1. Install mandatory infrastructure tooling required to run automation from a central control point:
   - Ansible
   - Terraform/OpenTofu
   - Git
   - Python
2. Configure SSH client state for automation execution:
   - Operator SSH keypair
   - `known_hosts` entries from explicit inventory/group vars data
3. Create a deterministic local workspace for IaC execution and state handling paths.

This role is intentionally environment-agnostic. No environment-specific hostnames, keys, addresses, or service instances are hard-coded.

## Role structure

- `defaults/main.yml` — environment-agnostic defaults for packages, SSH management, and workspace layout.
- `tasks/main.yml` — idempotent tasks to install tooling, configure SSH, and create control-plane directories.
- `meta/main.yml` — role metadata and collection requirement (`community.crypto`).
- `handlers/main.yml` — reserved for future handlers.

## Key variables

| Variable | Purpose | Default |
|---|---|---|
| `control_node_operator_user` | Local account that executes infrastructure commands | `ops` |
| `control_node_package_map` | OS-family package names for required tools | distro map with OpenTofu |
| `control_node_known_hosts_entries` | Explicit SSH known hosts entries | `[]` |
| `control_node_workspace_root` | Root path for control-plane workspace | `/opt/control-plane` |
| `control_node_workspace_directories` | Subdirectories for execution artifacts | `ansible`, `terraform`, `state`, `logs` |

## Example usage

```yaml
- hosts: control_plane
  become: true
  roles:
    - role: control_node
```

## Notes

- The role does not select cloud provider tooling.
- The role does not contain environment-specific values.
- Populate `control_node_known_hosts_entries` from inventory/group vars for each environment.
