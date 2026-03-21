# production Environment (`terraform/environments/production`)

## Purpose
Production promotion target after `staging` validation.

## Usage
1. Copy `backend.hcl.example` to `backend.hcl`.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`.
3. Run `terraform init -backend-config=backend.hcl` and `terraform apply`.
