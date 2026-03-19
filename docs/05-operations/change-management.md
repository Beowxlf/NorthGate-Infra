# Change Management

## Change Classes
- **Standard:** pre-approved low-risk repetitive changes.
- **Normal:** reviewed changes requiring planned execution.
- **Emergency:** urgent restoration/security changes with expedited approval.

## Required Artifacts Per Change
- Linked issue or change request identifier.
- Pull request with summary, risk, and rollback notes.
- Environment impact statement.

## Approval Rules
- At least one infrastructure reviewer for Terraform/OpenTofu changes.
- At least one configuration reviewer for Ansible changes.
- Security-impacting changes require explicit security review.

## Post-Change Review
- Verify intended state and monitoring signals.
- Record lessons learned for failed or degraded outcomes.
- Add/update decision log entries for policy or architecture shifts.
