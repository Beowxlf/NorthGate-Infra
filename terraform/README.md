# terraform/

## Purpose
`terraform/` contains Infrastructure-as-Code for provisioning NorthGate lab infrastructure with Terraform/OpenTofu.

## What belongs here
- Reusable modules in `terraform/modules/`.
- Environment root stacks in `terraform/environments/`.
- Provider, backend, variable, and output definitions for infrastructure provisioning.

## What does NOT belong here
- Host configuration tasks that belong in Ansible.
- Application code or application deployment logic.
- Hardcoded secret values.

## Structure contract
- `modules/` implement reusable infrastructure units.
- `environments/` compose modules for `test-core`, `workbench`, and `app-hosting`.
