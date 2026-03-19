# Deployment Workflow

## Git-to-Infrastructure Execution Path
1. **Design and change authoring in Git branch**
   - Update architecture/infrastructure docs when behavior or topology changes.
   - Implement IaC changes in Terraform/OpenTofu, Ansible, or Packer.
2. **Local validation**
   - Run formatting and static checks.
   - Run plan/syntax checks for changed layers.
3. **Pull request review**
   - Validate scope, dependency order, and layer boundaries.
4. **CI enforcement (phase 6 requirement)**
   - Terraform/OpenTofu fmt/validate/plan checks.
   - Ansible lint/syntax and playbook sanity checks.
   - Documentation structure/completeness checks.
5. **Controlled apply**
   - Apply provisioning changes to target environment.
   - Run Ansible configuration in defined dependency order.
   - Execute application deployment workflow for `app-hosting` when applicable.
6. **Post-deployment validation**
   - Service health checks.
   - Telemetry/alert status checks.
   - Change record update and closure.

## Promotion Sequence
`test-core` -> `workbench` -> `app-hosting`

Promotion can proceed only when the current environment has:
- successful provisioning/configuration validation,
- no unresolved critical alerts,
- documented change approval.

## Rollback Model
- Use Git revert/cherry-pick rollback commit.
- Re-apply Terraform/OpenTofu and Ansible to return to known-good state.
- For data-bearing services, execute documented restore procedures before service reopening.
