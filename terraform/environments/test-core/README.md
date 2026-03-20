# test-core Environment Example (`terraform/environments/test-core`)

## Purpose
Demonstrates how `terraform/modules/vm` is consumed for a foundational `test-core` workload (domain controller class VM).

## Why this structure
1. Environment root keeps only composition and environment-specific input values.
2. Reusable VM contract stays in `terraform/modules/vm` to prevent duplication across `test-core`, `workbench`, and `app-hosting`.
3. Base image input is supplied externally from Packer output data to enforce immutable-image workflows.

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Replace example values with environment-owned values.
3. Run `terraform init` and `terraform plan` from this directory.

## Note
This example intentionally excludes host configuration and application deployment logic. Those concerns are handled in Ansible and application delivery layers.
