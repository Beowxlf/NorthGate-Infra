# Configuration Standards

## Ansible Role Structure
Each role in `ansible/roles/<role_name>/` must include:
- `tasks/main.yml`
- `defaults/main.yml`
- `handlers/main.yml` (if services are managed)
- `templates/` and `files/` only when needed
- `README.md` with purpose, variables, and dependencies

## Variable Hierarchy
- Default role values in `defaults/main.yml`.
- Environment and host overrides from inventory `group_vars`/`host_vars`.
- Secrets are never stored in plaintext files.

## Idempotence Rules
- Tasks must be idempotent and converge on repeated runs.
- Shell commands require explicit `creates`, `removes`, or equivalent guards.
- Service restarts are handler-driven.

## Baseline Validation
Each role must define validation checks for:
- Package/service installation state.
- Configuration file placement and ownership.
- Service active/enabled state when applicable.
