# Deployment Workflow

## Canonical Execution Model
1. **Git change proposal**
   - Infrastructure intent documented and code updated in branch.
2. **AI-assisted authoring (optional)**
   - AI may draft Terraform/OpenTofu, Ansible, and docs changes.
   - Human reviewer validates correctness before merge.
3. **CI validation**
   - Format/lint checks.
   - Terraform/OpenTofu validation and plan checks.
   - Ansible lint/syntax checks.
4. **Provisioning**
   - Terraform/OpenTofu applies environment changes.
5. **Configuration**
   - Ansible applies baseline and role-specific configuration.
6. **Application deployment**
   - Application artifacts/configuration are deployed to app hosts.
7. **Monitoring and validation**
   - Health checks, telemetry, and service validation confirm success.

## Promotion Order
`test-core` -> `workbench` -> `app-hosting`

## Rollback Principle
Rollback is performed via Git revert plus controlled re-apply of Terraform/OpenTofu and Ansible.
