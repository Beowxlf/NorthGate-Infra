# Phase 5/6 CI Workflow — Continuous Validation and Failure Resilience Enforcement

## 1. Purpose
This workflow enforces deterministic infrastructure integrity, detection integrity, and controlled resilience validation for NorthGate-Infra by executing automated validation on code changes and optional failure simulation gates.

Alignment references:
1. Service catalog: `docs/02-infrastructure/service-catalog.md`
2. Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
3. Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Execution Triggers
Pipeline file: `.github/workflows/infrastructure-validation.yml`

The pipeline runs on:
1. `push` to any branch.
2. `pull_request` targeting any branch.
3. `workflow_dispatch` for optional Phase 6 failure simulation runs.

## 3. Stage Definition and Deterministic Sequence

| Stage | Gate Objective | Deterministic Input | Deterministic Output | Fail Condition |
|---|---|---|---|---|
| `validate` | Lint/syntax validation | repository source at commit SHA | pass/fail logs for Terraform/Ansible/schema checks | any lint/syntax/schema error |
| `build` | Image definition validation | Packer templates in repo | pass/fail validation log for Linux/Windows templates | any packer init/validate failure |
| `provision` | Terraform plan simulation | Terraform code + example vars | generated `tfplan` artifact | plan command non-zero |
| `configure` | Config validation and drift gate | Ansible playbooks/inventory + current state | check-mode output + `drift-report.json` | check-mode fails OR drift report status=`failure` |
| `detection_validation` | Attack-to-alert integrity | Caldera/Wazuh endpoints + expected alert mapping | detection report + integrity report + summary artifact | missing alerts OR service/integrity check failure |
| `failure_validation` (optional) | Controlled resilience validation under failure | selected simulation flag + target host + credentials | one or more `failure-validation-report-*.json` artifacts | degradation not observed as expected OR recovery fails OR baseline not restored |

## 4. Failure Contract (Explicit)
A pipeline run is **failed** when any of the following are true:
1. Infrastructure syntax is invalid.
2. Packer templates cannot be validated.
3. Terraform simulation (`plan`) errors.
4. Ansible check-mode indicates failed tasks.
5. Drift check detects `changed_total > 0` or `failed_total > 0`.
6. Detection validation reports missing expected Wazuh rule IDs.
7. Domain, DNS, Wazuh agent count, or application health checks fail.
8. Optional failure validation does not produce expected controlled degradation.
9. Optional failure validation cannot restore baseline automatically.

## 5. Optional Phase 6 Failure Stage
Failure simulation is run only for manual dispatch with one or more flags enabled:
- `simulate_dc_failure`
- `simulate_dns_failure`
- `simulate_wazuh_failure`
- `simulate_endpoint_failure`
- `simulate_application_failure`

Required secret mappings for Phase 6 execution:
- Access: `FAILURE_SSH_USER`, `FAILURE_SSH_KEY_PATH` (or passwordless SSH mechanism), optional `FAILURE_SSH_PORT`
- Target hosts: `FAILURE_DC_HOST`, `FAILURE_DNS_HOST`, `FAILURE_WAZUH_HOST`, `FAILURE_ENDPOINT_HOST`, `FAILURE_APPLICATION_HOST`

Each enabled scenario runs `scripts/run_failure_validation.sh` and emits one scenario-specific evidence file.

## 6. Evidence and Reporting Contract
Every successful or failed run must produce machine-readable evidence:
1. `artifacts/detection-validation-report.json`
2. `artifacts/system-integrity-report.json`
3. `artifacts/drift-report.json`
4. `artifacts/validation-summary.json`
5. `artifacts/failure-validation-report*.json` (for optional Phase 6 scenario runs)

## 7. Rollback Expectations
On validation failure:
1. No automatic apply/deploy is executed by this workflow.
2. Failing commit is corrected with a new commit.
3. If change has already reached runtime by external process, rerun Ansible baseline and redeploy pinned artifacts from repository definitions.
4. Re-run full pipeline; promotion is allowed only after all gates pass.
