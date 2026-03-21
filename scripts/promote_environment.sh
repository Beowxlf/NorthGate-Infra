#!/usr/bin/env bash
set -euo pipefail

SOURCE_ENV="${1:-}"
TARGET_ENV="${2:-}"
RELEASE_VERSION="${3:-}"

if [[ -z "${SOURCE_ENV}" || -z "${TARGET_ENV}" || -z "${RELEASE_VERSION}" ]]; then
  echo "Usage: $(basename "$0") <source_env> <target_env> <release_version>" >&2
  exit 1
fi

case "${SOURCE_ENV}:${TARGET_ENV}" in
  test-core:staging|staging:production) ;;
  *)
    echo "Invalid promotion path: ${SOURCE_ENV} -> ${TARGET_ENV}" >&2
    exit 1
    ;;
esac

VALIDATION_FILE="artifacts/${SOURCE_ENV}-validation-summary.json"
if [[ ! -f "${VALIDATION_FILE}" ]]; then
  echo "Missing validation evidence: ${VALIDATION_FILE}" >&2
  exit 1
fi

for key in ci_success detection_validation_success failure_validation_success; do
  status="$(jq -r --arg key "$key" '.[$key] // "false"' "${VALIDATION_FILE}")"
  if [[ "${status}" != "true" ]]; then
    echo "Promotion blocked: ${key}=${status}" >&2
    exit 1
  fi
done

mkdir -p artifacts
jq -nc \
  --arg source "${SOURCE_ENV}" \
  --arg target "${TARGET_ENV}" \
  --arg release_version "${RELEASE_VERSION}" \
  --arg promoted_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{source_environment:$source,target_environment:$target,release_version:$release_version,promoted_at:$promoted_at,status:"promoted"}' \
  > "artifacts/${TARGET_ENV}-promotion.json"

cat "artifacts/${TARGET_ENV}-promotion.json"
echo "Promotion completed: ${SOURCE_ENV} -> ${TARGET_ENV}"
