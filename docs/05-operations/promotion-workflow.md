# Phase 7 Promotion Workflow

## 1. Deterministic Promotion Path
1. `test-core` -> `staging`
2. `staging` -> `production`

Direct promotion from `test-core` to `production` is prohibited.

## 2. Required Validation Gates Before Any Promotion
Promotion is allowed only when the source environment has all three statuses set to `true`:
1. `ci_success`
2. `detection_validation_success`
3. `failure_validation_success`

Enforcement implementation:
- Script gate: `scripts/promote_environment.sh`
- CI gate: `.github/workflows/infrastructure-validation.yml` (`failure_validation` job and downstream promotion jobs)

## 3. Approval Gates
1. `staging` promotion requires CI completion and repository-level workflow approval.
2. `production` promotion requires `source_environment=staging` and GitHub `production` environment protection approval.
3. Manual promotion override is prohibited.

## 4. Versioned Promotion Contract
Every promotion includes `release_version` and commit SHA evidence:
- CI artifact: `artifacts/infrastructure-release.json`
- Local promotion artifact: `artifacts/<target>-promotion.json`

## 5. Block Conditions
Promotion is blocked when any are true:
1. Validation evidence file missing.
2. Any required gate status is not `true`.
3. Requested path is not `test-core -> staging` or `staging -> production`.
4. `simulate_promotion_failure=true` in CI dispatch.

## 6. Rollback Trigger
Rollback is mandatory if promoted environment validation fails after promotion. Use:
- `scripts/rollback_environment.sh <environment> <known_good_release_version>`
- Runbook: `docs/05-operations/environment-lifecycle.md`
