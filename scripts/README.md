# Scripts

Repository automation helpers (formatting, validation, and utility tasks).

Prefer deterministic, idempotent scripts that are safe for CI use.

## Phase 5 Validation Scripts
- `run_detection_validation.sh`: Triggers Caldera scenario execution and verifies expected Wazuh alerts.
- `run_system_integrity_checks.sh`: Validates domain reachability, DNS, Wazuh agent connectivity, and ScrambleIQ health.
- `check_ansible_drift.sh`: Executes Ansible check-mode drift gate and fails on state divergence.
