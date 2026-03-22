# CI Workflow — Validation, Promotion, Lifecycle, and Security Gates

Pipeline file: `.github/workflows/infrastructure-validation.yml`

## Trigger Modes
1. `push`
2. `pull_request`
3. `workflow_dispatch` (environment target, promotion, release version, rollback version, failure simulation)

## Deterministic Job Sequence
1. `validate` (matrix: `test-core`, `staging`, `production`)
2. `build`
3. `provision` (selected environment)
4. `configure` (selected environment)
5. `compliance_validation` (Phase 8 security hardening + policy compliance gate)
6. `detection_validation`
7. `failure_validation`
8. `create_release_marker`
9. `promote_staging` or `promote_production` (dispatch-only, gated)
10. `rollback` (optional dispatch-only, with rollback version)

## Security and Compliance Gate Behavior
- `compliance_validation` runs `scripts/run_compliance_checks.sh`.
- The job generates and uploads:
  - `artifacts/compliance-report.json`
  - `artifacts/drift-report.json`
- Any non-compliance returns non-zero and fails the pipeline.
- Promotion is blocked by `needs` dependencies when compliance fails.

## Promotion Controls
- Promotion input requires `promote=true`.
- Allowed path enforcement:
  - `test-core -> staging`
  - `staging -> production`
- Promotion automatically blocks on upstream gate failure due to `needs` dependency.
- Optional simulated failure (`simulate_promotion_failure=true`) forces gate failure for control validation.

## Versioned State and Rollback Controls
- Dispatch requires `release_version` (infrastructure version marker).
- Workflow publishes `artifacts/infrastructure-release.json` containing release version and commit SHA.
- Rollback can be requested with `rollback_to_version`; rollback execution follows the Phase 7 lifecycle runbook.
