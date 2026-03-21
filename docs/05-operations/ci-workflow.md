# Phase 5 CI Workflow — Continuous Validation and Enforcement

## 1. Purpose
This workflow enforces deterministic infrastructure and detection integrity for NorthGate-Infra by executing automated validation on every code change and blocking merges/deployments when integrity gates fail.

Alignment references:
1. Service catalog: `docs/02-infrastructure/service-catalog.md`
2. Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
3. Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Execution Triggers
Pipeline file: `.github/workflows/infrastructure-validation.yml`

The pipeline runs on:
1. `push` to any branch.
2. `pull_request` targeting any branch.

## 3. Stage Definition and Deterministic Sequence

| Stage | Gate Objective | Deterministic Input | Deterministic Output | Fail Condition |
|---|---|---|---|---|
| `validate` | Lint/syntax validation | repository source at commit SHA | pass/fail logs for Terraform/Ansible/schema checks | any lint/syntax/schema error |
| `build` | Image definition validation | Packer templates in repo | pass/fail validation log for Linux/Windows templates | any packer init/validate failure |
| `provision` | Terraform plan simulation | Terraform code + example vars | generated `tfplan` artifact | plan command non-zero |
| `configure` | Config validation and drift gate | Ansible playbooks/inventory + current state | check-mode output + `drift-report.json` | check-mode fails OR drift report status=`failure` |
| `detection_validation` | Attack-to-alert integrity | Caldera/Wazuh endpoints + expected alert mapping | detection report + integrity report + summary artifact | missing alerts OR service/integrity check failure |

## 4. Failure Contract (Explicit)
A pipeline run is **failed** when any of the following are true:
1. Infrastructure syntax is invalid.
2. Packer templates cannot be validated.
3. Terraform simulation (`plan`) errors.
4. Ansible check-mode indicates failed tasks.
5. Drift check detects `changed_total > 0` or `failed_total > 0`.
6. Detection validation reports missing expected Wazuh rule IDs.
7. Domain, DNS, Wazuh agent count, or ScrambleIQ health checks fail.

A failed pipeline blocks promotion to protected branches.

## 5. Drift Definition and Enforcement
Drift is defined as either of the following:
1. **Manual changes**: host or service state modified outside repository-controlled Ansible/Terraform/Packer paths.
2. **Configuration mismatch**: Ansible `--check` execution reports `changed > 0` for managed playbooks.

Enforcement:
1. `scripts/check_ansible_drift.sh` runs in the `configure` stage.
2. Drift is encoded into `artifacts/drift-report.json`.
3. Non-zero drift immediately fails the stage.

## 6. Detection Reliability Enforcement
Detection reliability is enforced by `scripts/run_detection_validation.sh` using `detection/validation/expected-alerts.json`:
1. Trigger Caldera operation for a named scenario.
2. Wait for operation completion within bounded timeout.
3. Query Wazuh alerts over bounded lookback.
4. Assert all expected rule IDs are present.
5. Emit `artifacts/detection-validation-report.json` and fail explicitly on missing alerts.

## 7. System Integrity Checks
`scripts/run_system_integrity_checks.sh` enforces runtime service gates:
1. Managed domain URL responds.
2. DNS resolution returns a record for managed domain.
3. Wazuh active agent count meets required minimum.
4. ScrambleIQ health endpoint responds.

Output: `artifacts/system-integrity-report.json`.

## 8. Evidence and Reporting Contract
Every successful or failed run must produce machine-readable evidence:
1. `artifacts/detection-validation-report.json`
2. `artifacts/system-integrity-report.json`
3. `artifacts/drift-report.json`
4. `artifacts/validation-summary.json`

`validation-summary.json` includes:
- attack execution result
- detection result
- system integrity result

## 9. Failure Scenario Definitions (Required Validation Set)

| Scenario ID | Injection Method | Expected Outcome |
|---|---|---|
| `missing_detection` | `SIMULATE_MISSING_DETECTION=1 scripts/run_detection_validation.sh ...` | script exits non-zero; report status=`failure`; missing rule IDs listed |
| `service_down` | `SIMULATE_SERVICE_DOWN=1 scripts/run_system_integrity_checks.sh` | script exits non-zero; ScrambleIQ check fails in report |
| `drift_present` | `SIMULATE_DRIFT=1 scripts/check_ansible_drift.sh` | script exits non-zero; drift report status=`failure` |

These scenario checks prove explicit pass/fail behavior for core integrity controls.

## 10. Rollback Expectations
On validation failure:
1. No automatic apply/deploy is executed by this workflow.
2. Failing commit is corrected with a new commit.
3. If change has already reached runtime by external process, rerun Ansible baseline and redeploy pinned artifacts from repository definitions.
4. Re-run full pipeline; promotion is allowed only after all gates pass.

## 11. Manual Override Rules
Manual override is restricted and traceable:
1. Overrides are allowed only for emergency restoration with incident ticket reference.
2. Override must include explicit expiration timestamp and owning approver.
3. Override does not waive post-incident remediation; failed gate root cause must be fixed in repository code.
4. UNKNOWN data required for override decision must be documented as `UNKNOWN` in operations records.

## 12. Required Secrets / Inputs
The detection and integrity stages require CI secrets:
- `CALDERA_URL`
- `CALDERA_API_KEY`
- `WAZUH_URL`
- `WAZUH_USERNAME`
- `WAZUH_PASSWORD`
- `DOMAIN_URL`
- `DNS_QUERY_NAME`
- `SCRAMBLEIQ_URL`
- `SCRAMBLEIQ_API_KEY` (optional for protected health endpoint)
- `EXPECTED_WAZUH_AGENTS`

If any required value is missing, scripts fail fast and pipeline status is `failure`.
