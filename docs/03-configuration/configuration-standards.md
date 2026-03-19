# Configuration Standards

## Purpose
Defines mandatory standards for Ansible-managed host and service configuration.

## Global Rules
- All managed configuration changes are role-based and idempotent.
- No manual configuration drift is accepted as permanent state.
- Environment differences are driven by inventory/group variables, not role forks.

## Naming and Structure
- Roles use service-centric names aligned with catalog entries (e.g., `domain_controller`, `wazuh_manager`, `scrambleiq_app`).
- Variables follow `ng_<env>_<service>_<setting>` where environment-specific.
- Playbooks sequence foundational dependencies before dependent services.

## Secrets Handling
- Sensitive values are stored through repository-approved encrypted mechanisms.
- Plaintext secrets are prohibited in tracked files.
- Secret references must be explicit in role defaults/vars documentation.

## Validation Expectations
- Role syntax and lint checks pass in CI.
- Critical service roles include post-task health checks.
- Failed validation blocks promotion to downstream environments.
