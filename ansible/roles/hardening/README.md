# hardening role

Deterministic host hardening and policy enforcement role.

## Enforced controls
- SSH hardening (root login disabled, key-based authentication only)
- Host firewall deny-by-default with explicit allow-list
- Least-privilege users and non-interactive service accounts
- Service minimization with explicit disable list
- Secret-source assertions (required environment variables)
- Logging path presence assertions
