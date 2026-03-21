# Terraform Environments

Deterministic environment roots:
- `test-core`
- `staging`
- `production`

## State Isolation Contract
Each environment must initialize with its own backend config file and state path.

Examples:
- `terraform -chdir=terraform/environments/test-core init -backend-config=backend.hcl`
- `terraform -chdir=terraform/environments/staging init -backend-config=backend.hcl`
- `terraform -chdir=terraform/environments/production init -backend-config=backend.hcl`

Reference backend templates:
- `terraform/environments/test-core/backend.hcl.example`
- `terraform/environments/staging/backend.hcl.example`
- `terraform/environments/production/backend.hcl.example`

No environment may read or write another environment state file.
