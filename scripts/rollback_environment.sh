#!/usr/bin/env bash
set -euo pipefail

TARGET_ENV="${1:-}"
ROLLBACK_VERSION="${2:-}"

if [[ -z "${TARGET_ENV}" || -z "${ROLLBACK_VERSION}" ]]; then
  echo "Usage: $(basename "$0") <target_env> <rollback_version>" >&2
  exit 1
fi

mkdir -p artifacts
jq -nc \
  --arg environment "${TARGET_ENV}" \
  --arg rollback_version "${ROLLBACK_VERSION}" \
  --arg rolled_back_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{environment:$environment,rollback_version:$rollback_version,rolled_back_at:$rolled_back_at,status:"rollback-ready"}' \
  > "artifacts/${TARGET_ENV}-rollback.json"

cat "artifacts/${TARGET_ENV}-rollback.json"
echo "Rollback plan recorded for ${TARGET_ENV} to ${ROLLBACK_VERSION}"
