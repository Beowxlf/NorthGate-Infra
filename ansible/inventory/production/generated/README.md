# Generated Inventory Artifacts

This directory stores generated inventory outputs from Terraform integration.

## Generate

```bash
python3 scripts/render_ansible_inventory.py \
  --terraform-dir terraform/environments/test-core \
  --output ansible/inventory/test-core/generated/hosts.auto.json
```
