# Environment: app-hosting

## Purpose
`app-hosting` provides stable long-running infrastructure for lab-hosted applications.

## Characteristics
- Persistent environment with controlled release windows.
- Backup and restore procedures are mandatory.
- Capacity and availability prioritized over rapid churn.

## Expected VM Roles
- `ctl`: highly controlled administrative node(s)
- `cfg`: configuration execution node(s)
- `app`: multiple service hosts
- `obs`: dedicated monitoring/logging host(s)

## Change Policy
- Promotion only from validated changes in lower environments.
- Emergency changes require follow-up decision log entry.

## Validation Gates
- Successful apply/configure cycle during maintenance window.
- Service SLO checks and monitoring signal verification.
- Backup verification and rollback readiness check.
