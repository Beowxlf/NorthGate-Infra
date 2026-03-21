# Phase 6 Resilience Metrics

## 1. Purpose
This document defines the resilience metrics used to evaluate failure behavior and recovery guarantees.

Alignment references:
1. Service catalog: `docs/02-infrastructure/service-catalog.md`
2. Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
3. Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Metric Definitions

| Metric | Definition | Data Source | Pass Criteria |
|---|---|---|---|
| Detection continuity during failure | Status of detection pipeline when a non-Wazuh component fails | `observation.detection_pipeline_continuity.status` in `artifacts/failure-validation-report.json` | `continuous` for non-Wazuh scenarios; `degraded_as_expected` for Wazuh failure scenario |
| Recovery time | Seconds from scenario start until post-recovery baseline validation pass | `observation.recovery_validation.recovery_time_seconds` in `artifacts/failure-validation-report.json` | Less than or equal to the scenario SLO threshold (default control threshold: 600 seconds) |
| Service availability impact | Observed degradation of integrity checks during injected failure | `observation.degradation_validation.status` in `artifacts/failure-validation-report.json` | `degraded_as_expected` for each scenario |
| Alert integrity | Evidence that expected failure mode is represented in validation output and not silent | `status` + scenario observation fields in `artifacts/failure-validation-report.json` | Validation run status=`success`; no unexpected detection degradation |

## 3. Recovery Validation Guarantees
The automation confirms recovery without manual intervention by enforcing:
1. deterministic reverse action through `scripts/inject_failure.sh recover ...`,
2. post-recovery baseline check through `scripts/run_system_integrity_checks.sh`,
3. explicit pass/fail report in `artifacts/failure-validation-report.json`.

## 4. Component-Level Recovery Expectations

| Component | Recovery Mechanism | Validation Signal |
|---|---|---|
| DC services | Restart service (or remove temporary isolation rules) via recovery action | Baseline integrity checks return to pass state |
| Wazuh ingestion | Restart `wazuh-manager` and verify manager/agent health | Detection continuity and system integrity checks pass |
| Application availability | Restart application service and confirm health endpoint | Application-integrity check path returns success |

## 5. Reporting Contract
Each resilience test execution must produce:
1. scenario executed,
2. observed behavior,
3. recovery success/failure,
4. deterministic pass/fail status.

Required artifact: `artifacts/failure-validation-report.json`.
