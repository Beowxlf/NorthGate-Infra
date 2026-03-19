# Environment Model

## Environment Definitions

### test-core
- Purpose: validate IaC and baseline configuration changes.
- Stability target: disposable and reproducible.
- Data policy: no persistent business data.

### workbench
- Purpose: shared engineer sandbox for infrastructure experiments.
- Stability target: semi-persistent; frequent change expected.
- Data policy: non-sensitive test data only.

### app-hosting
- Purpose: stable long-running services for lab users.
- Stability target: high stability and controlled change windows.
- Data policy: persistent service data with backups.

## Promotion Expectations
- Changes are developed and validated in `test-core`.
- Candidate changes are exercised in `workbench` for integration behavior.
- Approved changes are promoted to `app-hosting`.

## Drift Policy
- Manual changes in environments are prohibited unless documented emergency action.
- Drift is corrected by code changes and re-apply, not ad hoc edits.
