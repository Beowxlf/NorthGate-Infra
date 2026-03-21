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
4. **CI enforcement**
   - Terraform/OpenTofu fmt/validate/plan checks for `test-core`, `staging`, `production`.
   - Ansible lint/syntax checks using environment-specific inventories.
   - Validation gates for detection and failure resilience.
5. **Controlled apply**
   - Apply provisioning changes to selected environment only.
   - Run Ansible configuration in defined dependency order.
6. **Post-deployment validation**
   - Service health checks.
   - Telemetry/alert status checks.
   - Change record update and closure.

## Promotion Sequence
`test-core` -> `staging` -> `production`

Promotion is blocked unless source environment has:
- successful CI gate status,
- successful detection validation,
- successful failure validation,
- explicit approval for target environment.

## Rollback Model
- Select known-good infrastructure version label.
- Record rollback execution using `scripts/rollback_environment.sh`.
- Re-apply Terraform/OpenTofu and Ansible to return to known-good state.
- Re-run full pipeline before re-attempting promotion.
