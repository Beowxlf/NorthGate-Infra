# Environment Lifecycle Management (Phase 7)

## 1. Environment Purpose
| Environment | Purpose | Change Tolerance | Promotion Role |
|---|---|---|---|
| `test-core` | Integration validation and attack/detection verification | High (controlled) | Source for `staging` |
| `staging` | Pre-production release certification | Medium | Source for `production` |
| `production` | Operational runtime baseline | Low | Final target |

## 2. Lifecycle Stages
1. **Build**: Terraform/Packer/Ansible definitions validated in CI.
2. **Deploy**: Environment-specific Terraform plan/apply and Ansible execution.
3. **Validate**: CI checks + detection validation + failure validation.
4. **Promote**: Controlled forward movement to next environment.
5. **Operate**: Drift checks and continuous validation.
6. **Rollback (if required)**: Return to previous known-good version.

## 3. Environment Isolation Rules
1. No shared Terraform state files across environments.
2. No shared Ansible inventory roots across environments.
3. No cross-environment runtime dependencies are permitted unless explicitly documented as `UNKNOWN` and approved.
4. Communication boundaries are explicit and one-directional for promotion metadata only (artifacts and approvals), not service runtime traffic.

## 4. Deployment Strategy
1. Sequential rollout only: `test-core` then `staging` then `production`.
2. Promotion-based deployment only; ad hoc environment skips are prohibited.
3. Failure at any gate halts downstream promotion automatically.

## 5. Versioning Strategy
1. Each promotion run uses a required `release_version` label (`infra-YYYY.MM.DD.N`).
2. Release metadata is stored in `artifacts/infrastructure-release.json` during CI dispatch.
3. Promotion records are stored per target environment (`artifacts/<env>-promotion.json`).

## 6. Rollback Procedure
1. Identify latest known-good release version from promotion/release artifacts.
2. Execute deterministic rollback record:
   - `scripts/rollback_environment.sh <environment> <release_version>`
3. Re-apply pinned Terraform/Ansible definitions associated with rollback version.
4. Re-run validation gates before reopening next promotion attempt.

## 7. Validation Demonstration Contract
Phase 7 validation is executed with:
- `scripts/run_phase7_lifecycle_demo.sh`

This demonstration proves:
1. deploy to `test-core`
2. promote to `staging`
3. promote to `production`
4. simulate failure and block promotion
5. create rollback record to known-good version
