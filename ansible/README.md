# ansible/

## Purpose
`ansible/` contains post-provisioning configuration code for host baselines and service configuration.

## What belongs here
- Reusable roles in `ansible/roles/`.
- Inventory definitions in `ansible/inventories/`.
- Executable orchestration playbooks in `ansible/playbooks/`.

## What does NOT belong here
- Infrastructure provisioning logic that belongs in Terraform/OpenTofu.
- Image build pipelines that belong in Packer.
- Plaintext secret values.

## Execution contract
Terraform/OpenTofu creates infrastructure first; Ansible then converges hosts to defined baseline and role-specific state.
