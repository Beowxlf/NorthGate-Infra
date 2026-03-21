# test-core Environment (`terraform/environments/test-core`)

## Purpose
Executable Phase 1 environment stack for deterministic provisioning of:

1. Linux Ansible control node
2. Windows Domain Controller
3. Linux Wazuh manager node
4. Isolated `test-core` libvirt network

## Deterministic pipeline contract
- Terraform provisions compute/network/storage resources only.
- Terraform exports inventory-compatible outputs (`ansible_inventory_data`, `ansible_inventory_yaml`, `ansible_inventory_json`).
- `scripts/render_ansible_inventory.py` converts Terraform output to a committed Ansible inventory artifact path.
- Ansible playbooks in `ansible/playbooks/` handle all host/service configuration.

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and set image IDs from Packer builds.
2. Run:
   - `terraform init`
   - `terraform apply`
3. Generate inventory from outputs:
   - `python3 ../../../scripts/render_ansible_inventory.py --terraform-dir . --output ../../ansible/inventory/test-core/generated/hosts.auto.json`
4. Run Ansible orchestration:
   - `ansible-playbook -i ../../ansible/inventory/test-core/generated/hosts.auto.json ../../ansible/playbooks/phase_1_test_core.yml`
5. Re-run Ansible command to verify idempotency.


## State backend
- Copy `backend.hcl.example` to `backend.hcl` and run `terraform init -backend-config=backend.hcl` to keep environment state isolated.
