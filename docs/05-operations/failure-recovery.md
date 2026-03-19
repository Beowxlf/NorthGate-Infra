# Failure Recovery

## Failure Categories
1. **Provisioning failure:** Terraform/OpenTofu apply failed or partial state.
2. **Configuration failure:** Ansible role execution failed or host drift detected.
3. **Service failure:** application unhealthy after deployment.
4. **State/artifact loss:** Terraform state backend or image artifacts unavailable.

## Recovery Strategy
- Stop further promotion.
- Capture failure evidence (logs, state output, host diagnostics).
- Restore known-good state from Git-tagged release or rollback commit.
- Re-run provisioning/configuration in controlled sequence.

## Minimum Recovery Runbooks
- Terraform/OpenTofu state restore and lock recovery.
- Ansible re-convergence run for failed host groups.
- Application rollback to previous release artifact.
- Backup restore test for persistent storage.

## Recovery Validation
- Infrastructure state matches expected plan.
- Configuration converges without unplanned drift.
- Service health checks return healthy status.
