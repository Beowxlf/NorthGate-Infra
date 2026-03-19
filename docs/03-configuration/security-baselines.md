# Security Baselines

## Secret Handling
- Secrets are sourced from encrypted stores (for example: Ansible Vault or external secret manager integration).
- Secret placeholders may exist in Git; secret values must not.
- CI must fail on detected plaintext secret patterns.

## Access Control
- SSH key-based authentication only.
- Privileged access restricted to approved operator groups.
- Service accounts use least privilege.

## Host Hardening Minimums
- Disable unused network services.
- Enforce firewall default deny with explicit allow rules.
- Enforce baseline audit logging.
- Apply OS security updates during maintenance windows.

## Terraform/OpenTofu Security Rules
- Input variables that carry sensitive values are marked `sensitive = true`.
- State backend access is restricted to automation identities and approved operators.

## Evidence and Auditability
- Each deployment run must produce logs/artifacts traceable to a Git commit.
- Security baseline deviations require an entry in `docs/06-decisions/decision-log.md`.
