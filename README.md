# northgate-infra

Production-grade Infrastructure as Code repository for NorthGate.

## Layout
- `docs/` — source-of-truth documentation for architecture, infrastructure, and operations.
- `terraform/` — reusable modules and environment stacks.
- `ansible/` — configuration management roles, inventories, and playbooks.
- `packer/` — machine image definitions and build templates.
- `scripts/` — helper scripts for automation and developer workflows.
- `.github/workflows/` — CI/CD pipelines and policy checks.

This scaffold is intentionally minimal and designed to scale over time.
