# Failure and Recovery

## Recovery Objectives
- Restore minimum viable platform in dependency order.
- Preserve deterministic behavior during rebuild and restore.
- Validate recoverability as a recurring operational exercise.

## Dependency-Based Recovery Order
1. **Network and foundational provisioning primitives**
2. **Identity and naming (Domain Controller, DNS, time)**
3. **Control-plane access (jump host, control node)**
4. **Security/observability (Wazuh, Prometheus, Grafana)**
5. **Security testing tooling (Caldera stack)**
6. **Application hosting (proxy, app, DB, workers)**

## Phase 6 Controlled Failure Recovery Validation
Recovery validation is executed by `scripts/run_failure_validation.sh` for each scenario and enforces this deterministic sequence:
1. Run baseline system integrity checks.
2. Inject bounded failure with `scripts/inject_failure.sh inject ...`.
3. Verify expected degradation behavior.
4. Trigger automated recovery with `scripts/inject_failure.sh recover ...`.
5. Re-run baseline checks to prove known-good restoration.

Any deviation from this sequence is non-compliant.

## Component Recovery Guarantees

| Component | Injection Mode | Automated Recovery Mode | Required Validation |
|---|---|---|---|
| DC services | service stop or temporary isolation | service start or temporary rule removal | post-recovery baseline checks pass |
| DNS services | service stop | service start | DNS resolution checks pass |
| Wazuh ingestion | `wazuh-manager` stop | `wazuh-manager` start | manager health and agent thresholds restored |
| Endpoint telemetry | `wazuh-agent` stop | `wazuh-agent` start | endpoint telemetry path restored in integrity checks |
| Application availability | app service stop | app service start | app health endpoint check passes |

## Failure Scenarios to Validate
- Complete environment rebuild from zero.
- Loss of control node and restoration of automation capability.
- Identity service outage with dependent service restoration.
- Database failure with application recovery.
- Telemetry stack outage and monitoring restoration.
- Phase 6 bounded service failure scenarios defined in `docs/05-operations/failure-scenarios.md`.

## Recovery Procedure Rules
- Execute infrastructure recreation through Terraform/OpenTofu first for infrastructure-level failures.
- Reapply Ansible roles in documented dependency order.
- Restore data from approved backups before opening dependent services.
- Record incident timeline, root cause, and permanent corrective IaC updates.
- Manual post-failure steps invalidate automated resilience evidence unless explicitly tracked as exception remediation.
