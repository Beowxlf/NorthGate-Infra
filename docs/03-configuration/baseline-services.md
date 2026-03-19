# Baseline Services

## Required Baseline Services
All managed VMs must include:
1. Time synchronization service.
2. Centralized logging agent.
3. SSH service with hardened settings.
4. Monitoring/exporter agent.
5. Package update baseline configuration.

## Role Mapping
- `role_common`: shared OS baseline.
- `role_security`: host hardening and audit settings.
- `role_monitoring`: metrics and logging integrations.
- `role_app_runtime`: runtime dependencies for app hosts.

## Deployment Order
1. `role_common`
2. `role_security`
3. `role_monitoring`
4. Role-specific runtime/app roles

## Exceptions
Any skipped baseline component must be documented in the environment file under `docs/04-environments/` with rationale.
