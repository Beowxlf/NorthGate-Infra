# Security Enforcement Operations (Phase 8)

## Enforcement Model
Security enforcement is continuous and deterministic through:
1. Ansible convergence (`ansible/playbooks/security_enforcement.yml` and `phase_5_validation_hooks.yml` import).
2. Policy validation (`scripts/run_compliance_checks.sh`).
3. Drift gate (`scripts/check_ansible_drift.sh`) including security playbooks.
4. CI promotion gate failure on any compliance violation.

## Compliance Checks
`run_compliance_checks.sh` enforces the following gates:
1. Policy artifact presence (`docs/03-configuration/security-policies.md`).
2. Hardening role structure and mandatory controls (SSH, firewall, least privilege, service minimization).
3. Policy/static alignment between `scripts/security_policy.json` and hardening defaults.
4. Ansible drift check execution with hardening playbook included.
5. Optional deterministic failure injection (`SIMULATE_POLICY_VIOLATION=1`).

Output artifact:
- `artifacts/compliance-report.json`

## Drift Detection
Drift is defined as either:
1. Any Ansible check-mode convergence delta (`changed > 0`) for protected playbooks.
2. Any failed assertions in hardening policy controls.
3. Any static policy mismatch detected by the compliance script.

Drift response contract:
1. CI job fails immediately.
2. Promotion jobs are blocked by `needs` dependencies.
3. Operator remediates via code change and re-runs pipeline.

## Response Expectations
When compliance fails:
1. Review `artifacts/compliance-report.json` and `artifacts/drift-report.json`.
2. Identify violated control IDs from `docs/03-configuration/security-policies.md`.
3. Remediate in Ansible role defaults/tasks or approved inventory vars.
4. Re-run compliance script and pipeline.
5. Promote only after compliance gate returns success.

## Deterministic Validation Sequence
1. Build and validate IaC/Ansible.
2. Apply hardening playbook in check/enforcement mode.
3. Run compliance script.
4. Fail gate intentionally (`SIMULATE_POLICY_VIOLATION=1`) to verify pipeline control.
5. Reset violation flag and confirm gate pass.
