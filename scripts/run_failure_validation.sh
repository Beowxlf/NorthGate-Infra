#!/usr/bin/env bash
set -euo pipefail

SCENARIO="${1:-}"
TARGET_HOST="${2:-}"
DURATION_SECONDS="${3:-90}"
REPORT_DIR="${VALIDATION_REPORT_DIR:-artifacts}"
REPORT_FILE="${REPORT_DIR}/failure-validation-report.json"

SYSTEM_CHECK_SCRIPT="${SYSTEM_CHECK_SCRIPT:-scripts/run_system_integrity_checks.sh}"
INJECT_SCRIPT="${INJECT_SCRIPT:-scripts/inject_failure.sh}"
DETECTION_CONTINUITY_REQUIRED="${DETECTION_CONTINUITY_REQUIRED:-1}"

WAZUH_URL="${WAZUH_URL:-}"
WAZUH_USERNAME="${WAZUH_USERNAME:-}"
WAZUH_PASSWORD="${WAZUH_PASSWORD:-}"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 2; }; }
need_cmd jq
need_cmd curl
need_cmd date

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") <scenario> <target_host> [duration_seconds]

Examples:
  $(basename "$0") wazuh_manager_failure wazuh01 120
  $(basename "$0") application_failure app01 90
USAGE
}

if [[ -z "${SCENARIO}" || -z "${TARGET_HOST}" ]]; then
  usage
  exit 1
fi

mkdir -p "${REPORT_DIR}"

baseline_status="failure"
failure_observation_status="failure"
recovery_status="failure"
detection_continuity_status="unknown"

baseline_error=""
failure_error=""
recovery_error=""

start_ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
start_epoch="$(date -u +%s)"

run_system_check() {
  local output_file="$1"
  if "${SYSTEM_CHECK_SCRIPT}" >"${output_file}" 2>"${output_file}.err"; then
    return 0
  fi
  return 1
}

check_detection_continuity() {
  if [[ "${DETECTION_CONTINUITY_REQUIRED}" != "1" ]]; then
    echo "skipped"
    return 0
  fi

  if [[ -z "${WAZUH_URL}" || -z "${WAZUH_USERNAME}" || -z "${WAZUH_PASSWORD}" ]]; then
    echo "missing_wazuh_credentials"
    return 0
  fi

  local token
  token="$(curl -fsS -u "${WAZUH_USERNAME}:${WAZUH_PASSWORD}" -X POST "${WAZUH_URL%/}/security/user/authenticate?raw=true")" || {
    echo "failed_to_authenticate"
    return 0
  }

  local manager_ok
  manager_ok="$(curl -fsS -H "Authorization: Bearer ${token}" "${WAZUH_URL%/}/manager/status" | jq -r '.data.affected_items[0].wazuh_manager_state // "unknown"' 2>/dev/null || true)"

  if [[ "${SCENARIO}" == "wazuh_manager_failure" ]]; then
    if [[ "${manager_ok}" == "stopped" || "${manager_ok}" == "unknown" ]]; then
      echo "degraded_as_expected"
    else
      echo "unexpected_manager_state:${manager_ok}"
    fi
  else
    if [[ "${manager_ok}" == "running" ]]; then
      echo "continuous"
    else
      echo "degraded_unexpectedly:${manager_ok}"
    fi
  fi
}

# Step 1: baseline validation
if run_system_check "${REPORT_DIR}/baseline-system-integrity.json"; then
  baseline_status="success"
else
  baseline_error="$(cat "${REPORT_DIR}/baseline-system-integrity.json.err" 2>/dev/null || true)"
fi

if [[ "${baseline_status}" != "success" ]]; then
  jq -nc \
    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg scenario "${SCENARIO}" \
    --arg target_host "${TARGET_HOST}" \
    --arg status "failure" \
    --arg baseline_status "${baseline_status}" \
    --arg baseline_error "${baseline_error}" \
    '{
      timestamp: $timestamp,
      scenario: $scenario,
      target_host: $target_host,
      status: $status,
      baseline: {status: $baseline_status, error: $baseline_error},
      failure_phase: {status: "not_started"},
      recovery_phase: {status: "not_started"}
    }' > "${REPORT_FILE}"
  cat "${REPORT_FILE}"
  echo "Baseline validation failed before injection" >&2
  exit 1
fi

# Step 2: inject failure
"${INJECT_SCRIPT}" inject "${SCENARIO}" "${TARGET_HOST}" 0

# Step 3: validate expected degradation behavior
if run_system_check "${REPORT_DIR}/failure-system-integrity.json"; then
  failure_observation_status="unexpected_no_degradation"
  failure_error="Failure scenario did not cause expected degradation"
else
  failure_observation_status="degraded_as_expected"
  failure_error="$(cat "${REPORT_DIR}/failure-system-integrity.json.err" 2>/dev/null || true)"
fi

detection_continuity_status="$(check_detection_continuity)"

sleep "${DURATION_SECONDS}"

# Step 4: recover
"${INJECT_SCRIPT}" recover "${SCENARIO}" "${TARGET_HOST}"

# Step 5: verify baseline restored
if run_system_check "${REPORT_DIR}/recovery-system-integrity.json"; then
  recovery_status="success"
else
  recovery_status="failure"
  recovery_error="$(cat "${REPORT_DIR}/recovery-system-integrity.json.err" 2>/dev/null || true)"
fi

end_epoch="$(date -u +%s)"
recovery_time_seconds="$((end_epoch - start_epoch))"
overall_status="success"

if [[ "${failure_observation_status}" != "degraded_as_expected" ]]; then
  overall_status="failure"
fi
if [[ "${recovery_status}" != "success" ]]; then
  overall_status="failure"
fi
if [[ "${detection_continuity_status}" == degraded_unexpectedly:* || "${detection_continuity_status}" == unexpected_manager_state:* ]]; then
  overall_status="failure"
fi

jq -nc \
  --arg timestamp "${start_ts}" \
  --arg completed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg scenario "${SCENARIO}" \
  --arg target_host "${TARGET_HOST}" \
  --arg status "${overall_status}" \
  --arg baseline_status "${baseline_status}" \
  --arg failure_status "${failure_observation_status}" \
  --arg failure_error "${failure_error}" \
  --arg recovery_status "${recovery_status}" \
  --arg recovery_error "${recovery_error}" \
  --arg detection_continuity_status "${detection_continuity_status}" \
  --argjson recovery_time_seconds "${recovery_time_seconds}" \
  --argjson duration_seconds "${DURATION_SECONDS}" \
  '{
    started_at: $timestamp,
    completed_at: $completed_at,
    scenario: $scenario,
    target_host: $target_host,
    configured_failure_duration_seconds: $duration_seconds,
    status: $status,
    observation: {
      baseline_precheck: {status: $baseline_status},
      degradation_validation: {status: $failure_status, detail: $failure_error},
      detection_pipeline_continuity: {status: $detection_continuity_status},
      recovery_validation: {
        status: $recovery_status,
        recovery_time_seconds: $recovery_time_seconds,
        detail: $recovery_error
      }
    }
  }' > "${REPORT_FILE}"

cat "${REPORT_FILE}"

if [[ "${overall_status}" != "success" ]]; then
  echo "Failure validation failed for ${SCENARIO}" >&2
  exit 1
fi

echo "Failure validation passed for ${SCENARIO}"
