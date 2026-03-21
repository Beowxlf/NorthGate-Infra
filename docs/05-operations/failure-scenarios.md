# Phase 6 Failure Scenario Definitions

## 1. Purpose
This document defines deterministic and reversible failure scenarios for resilience validation.

Alignment references:
1. Service catalog: `docs/02-infrastructure/service-catalog.md`
2. Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
3. Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Execution Contract
1. Failure injection is executed only through `scripts/inject_failure.sh`.
2. Validation orchestration is executed through `scripts/run_failure_validation.sh`.
3. Every scenario writes evidence to `artifacts/failure-validation-report.json`.
4. Every scenario must prove:
   1. expected degradation is observed,
   2. recovery runs without manual intervention,
   3. baseline state is restored.

## 3. Scenario Matrix

| Scenario Name | Trigger Method | Expected System Behavior | Unacceptable Outcomes | Recovery Expectations |
|---|---|---|---|---|
| `dc_failure` | `scripts/inject_failure.sh inject dc_failure <dc_host> <duration>` using `FAILURE_METHOD=service_stop` (or `isolate`) | Identity-dependent flows degrade in a controlled way; failure is detectable; core automation access remains available | Irreversible identity corruption, persistent DNS breakage, unrecoverable access loss | `recover dc_failure` restores DC service/network state and post-recovery integrity checks pass |
| `dns_failure` | `scripts/inject_failure.sh inject dns_failure <dns_host> <duration>` | DNS-dependent checks fail deterministically; endpoint/service hosts remain reachable by management channel | Name resolution remains broken after recovery; unmanaged config drift | `recover dns_failure` restarts DNS service and baseline validation succeeds |
| `wazuh_manager_failure` | `scripts/inject_failure.sh inject wazuh_manager_failure <wazuh_host> <duration>` | Alert ingestion is degraded as expected while other infrastructure checks remain bounded | Silent telemetry loss not detected by checks; manager remains down after recovery | `recover wazuh_manager_failure` returns manager to running state and agent connectivity returns to threshold |
| `endpoint_failure` | `scripts/inject_failure.sh inject endpoint_failure <endpoint_host> <duration>` | Endpoint agent telemetry from target host degrades; centralized platform remains available | Endpoint remains unmanaged after recovery; no alert about loss | `recover endpoint_failure` restores endpoint agent service and baseline checks pass |
| `application_failure` | `scripts/inject_failure.sh inject application_failure <app_host> <duration>` | Application health check fails during injection and succeeds after recovery | Extended outage after recovery; partial recovery without health pass | `recover application_failure` starts app service and health endpoint returns success |

## 4. Deterministic Inputs and Outputs

### Inputs
- Scenario identifier (`dc_failure`, `dns_failure`, `wazuh_manager_failure`, `endpoint_failure`, `application_failure`)
- Target host
- Failure duration (seconds)
- SSH execution context (`FAILURE_SSH_USER`, optional key/port)

### Outputs
- Injection state file: `artifacts/failure-state/<scenario>_<host>.env`
- Validation evidence: `artifacts/failure-validation-report.json`
- Intermediate evidence:
  - `artifacts/baseline-system-integrity.json`
  - `artifacts/failure-system-integrity.json`
  - `artifacts/recovery-system-integrity.json`

## 5. Safety Controls
1. Only reversible actions are allowed (service stop/start or temporary isolation rule insertion/removal).
2. No permanent configuration mutation is permitted.
3. Recovery action is mandatory for every injected scenario.
4. Manual intervention is treated as validation failure.
