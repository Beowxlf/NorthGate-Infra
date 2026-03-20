# common role

Baseline Linux configuration role intended for all managed Linux hosts.

## What it does

1. Updates package metadata and upgrades installed packages.
2. Installs baseline operational tools.
3. Creates a standard operations user.
4. Ensures time synchronization package/service are present and running.
5. Applies secure SSH daemon settings and restarts SSH only when configuration changes.

## Design constraints

- Idempotent tasks only (no shell-based mutable steps).
- No environment-specific values.
- No external role dependencies.
- No application service configuration.
