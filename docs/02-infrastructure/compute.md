# Compute Infrastructure

## VM Role Model
Each VM belongs to one primary role category:

1. **ctl (control):** orchestration endpoints, CI runners, and control-plane utilities.
2. **cfg (configuration):** configuration execution nodes and repositories (when isolated control host is required).
3. **app (application):** application runtime hosts.
4. **obs (observability):** monitoring and logging stack hosts.

## VM Naming Convention
Format: `ng-<env>-<role>-<index>`
- `env`: `test-core`, `workbench`, `app-hosting`.
- `role`: `ctl`, `cfg`, `app`, `obs`, or approved extension.
- `index`: two-digit sequence (`01`, `02`, ...).

## Sizing Standards
- VM size classes: `small`, `medium`, `large`.
- Terraform variables define vCPU, memory, and root disk per class.
- Environment roots map role -> size class explicitly.

## Lifecycle
- Base image built by Packer.
- VM provisioned by Terraform/OpenTofu.
- Host baseline applied by Ansible.
- Application payload deployed only after baseline validation.
