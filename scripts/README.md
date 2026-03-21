# Scripts

Repository automation helpers (formatting, validation, and utility tasks).

Prefer deterministic, idempotent scripts that are safe for CI use.

## Phase 5 Validation Scripts
- `run_detection_validation.sh`: Triggers Caldera scenario execution and verifies expected Wazuh alerts.
- `run_system_integrity_checks.sh`: Validates domain reachability, DNS, Wazuh agent connectivity, and ScrambleIQ health.
- `check_ansible_drift.sh`: Executes Ansible check-mode drift gate and fails on state divergence.

## Phase 6 Failure Engineering Scripts
- `inject_failure.sh`: Injects and recovers bounded failures (`dc_failure`, `dns_failure`, `wazuh_manager_failure`, `endpoint_failure`, `application_failure`) against targeted hosts.
- `run_failure_validation.sh`: Executes full resilience validation lifecycle (baseline, injection, degradation validation, recovery, baseline restoration) and writes `artifacts/failure-validation-report.json`.

## Phase 7 Promotion and Lifecycle Scripts
- `promote_environment.sh`: Enforces allowed promotion path and required gate evidence (`ci_success`, `detection_validation_success`, `failure_validation_success`).
- `rollback_environment.sh`: Records deterministic rollback execution target and version metadata.
- `run_phase7_lifecycle_demo.sh`: Demonstrates deploy/promote/failure-block/rollback lifecycle contract.
