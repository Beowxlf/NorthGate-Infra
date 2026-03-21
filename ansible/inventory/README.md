# Environment Inventory Model

## Scope
This directory defines deterministic, environment-scoped inventory models for:
- `test-core`
- `staging`
- `production`

Alignment references:
- Environment model: `docs/01-architecture/environment-model.md`
- Service catalog: `docs/02-infrastructure/service-catalog.md`
- Dependency model: `docs/01-architecture/service-dependency-model.md`

## Isolation Contract
1. Each environment has an independent inventory root (`ansible/inventory/<environment>/`).
2. Each environment has independent `group_vars` and `host_vars` definitions.
3. Environment artifacts from Terraform are written to environment-specific paths:
   - `../terraform/out/test-core-ansible-inventory.json`
   - `../terraform/out/staging-ansible-inventory.json`
   - `../terraform/out/production-ansible-inventory.json`
4. Cross-environment host references are prohibited.

## Execution Contract
Use explicit inventory selection per environment:

- `ansible-playbook -i ansible/inventory/test-core/hosts.yml ...`
- `ansible-playbook -i ansible/inventory/staging/hosts.yml ...`
- `ansible-playbook -i ansible/inventory/production/hosts.yml ...`

This enforces deterministic configuration and prevents runtime leakage across environments.
