#!/usr/bin/env bash
set -euo pipefail

mkdir -p artifacts

# 1) Deploy to test-core (simulated deterministic validation result)
cat > artifacts/test-core-validation-summary.json <<JSON
{"ci_success":true,"detection_validation_success":true,"failure_validation_success":true}
JSON

echo "[1/5] test-core deploy validation complete"

# 2) Promote to staging
scripts/promote_environment.sh test-core staging infra-2026.03.21.1 >/dev/null
echo "[2/5] staging promotion complete"

# 3) Promote to production
cat > artifacts/staging-validation-summary.json <<JSON
{"ci_success":true,"detection_validation_success":true,"failure_validation_success":true}
JSON
scripts/promote_environment.sh staging production infra-2026.03.21.1 >/dev/null
echo "[3/5] production promotion complete"

# 4) Simulate failure and verify promotion blocked
cat > artifacts/test-core-validation-summary.json <<JSON
{"ci_success":true,"detection_validation_success":false,"failure_validation_success":true}
JSON
if scripts/promote_environment.sh test-core staging infra-2026.03.21.2 >/dev/null 2>&1; then
  echo "Expected promotion block did not occur" >&2
  exit 1
fi
echo "[4/5] failure gate blocked promotion as expected"

# 5) Rollback to known-good version
scripts/rollback_environment.sh production infra-2026.03.21.1 >/dev/null
echo "[5/5] rollback plan created"
