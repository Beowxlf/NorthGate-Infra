#!/usr/bin/env bash
set -euo pipefail

SCENARIO_ID="${1:-phase3_blue_team_validation}"
DEFINITION_FILE="${DETECTION_DEFINITION_FILE:-detection/validation/expected-alerts.json}"
REPORT_DIR="${VALIDATION_REPORT_DIR:-artifacts}"
REPORT_FILE="${REPORT_DIR}/detection-validation-report.json"

CALDERA_URL="${CALDERA_URL:?CALDERA_URL is required}"
CALDERA_API_KEY="${CALDERA_API_KEY:?CALDERA_API_KEY is required}"
WAZUH_URL="${WAZUH_URL:?WAZUH_URL is required}"
WAZUH_USERNAME="${WAZUH_USERNAME:?WAZUH_USERNAME is required}"
WAZUH_PASSWORD="${WAZUH_PASSWORD:?WAZUH_PASSWORD is required}"

CALDERA_WAIT_SECONDS="${CALDERA_WAIT_SECONDS:-180}"
CALDERA_POLL_SECONDS="${CALDERA_POLL_SECONDS:-10}"
WAZUH_LOOKBACK_MINUTES="${WAZUH_LOOKBACK_MINUTES:-30}"
SIMULATE_MISSING_DETECTION="${SIMULATE_MISSING_DETECTION:-0}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 2; }
}

need_cmd curl
need_cmd jq
need_cmd python3

mkdir -p "${REPORT_DIR}"

SCENARIO_JSON="$(python3 - <<'PY' "${DEFINITION_FILE}" "${SCENARIO_ID}"
import json
import sys

path, sid = sys.argv[1], sys.argv[2]
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)
for scenario in data.get('scenarios', []):
    if scenario.get('id') == sid:
        print(json.dumps(scenario))
        break
else:
    raise SystemExit(f"Scenario not found: {sid}")
PY
)"

OPERATION_PAYLOAD="$(jq -nc --argjson scenario "${SCENARIO_JSON}" '{
  name: $scenario.caldera.operation_name,
  adversary_id: $scenario.caldera.adversary_id,
  planner: $scenario.caldera.planner_id,
  source: $scenario.caldera.source_id,
  autonomous: 1
}')"

echo "[INFO] Triggering Caldera operation for scenario ${SCENARIO_ID}"
CREATE_OPERATION_RESPONSE="$(curl -fsS -X POST "${CALDERA_URL%/}/api/v2/operations" \
  -H "KEY: ${CALDERA_API_KEY}" \
  -H 'Content-Type: application/json' \
  -d "${OPERATION_PAYLOAD}")"

OPERATION_ID="$(echo "${CREATE_OPERATION_RESPONSE}" | jq -r '.id // empty')"
if [[ -z "${OPERATION_ID}" ]]; then
  echo "Failed to parse Caldera operation id" >&2
  exit 1
fi

echo "[INFO] Caldera operation id: ${OPERATION_ID}"

elapsed=0
operation_state=""
while (( elapsed <= CALDERA_WAIT_SECONDS )); do
  STATUS_RESPONSE="$(curl -fsS -X GET "${CALDERA_URL%/}/api/v2/operations/${OPERATION_ID}" -H "KEY: ${CALDERA_API_KEY}")"
  operation_state="$(echo "${STATUS_RESPONSE}" | jq -r '.state // .status // "unknown"')"

  if [[ "${operation_state}" == "finished" || "${operation_state}" == "completed" ]]; then
    break
  fi

  sleep "${CALDERA_POLL_SECONDS}"
  elapsed=$((elapsed + CALDERA_POLL_SECONDS))
done

if [[ "${operation_state}" != "finished" && "${operation_state}" != "completed" ]]; then
  echo "Caldera operation did not finish within timeout. Last state=${operation_state}" >&2
  exit 1
fi

AUTH_TOKEN="$(curl -fsS -u "${WAZUH_USERNAME}:${WAZUH_PASSWORD}" -X POST "${WAZUH_URL%/}/security/user/authenticate?raw=true")"
if [[ -z "${AUTH_TOKEN}" ]]; then
  echo "Failed to obtain Wazuh auth token" >&2
  exit 1
fi

expected_rule_ids="$(echo "${SCENARIO_JSON}" | jq '[.mapping[].expected_alert_rule_id]')"
if [[ "${SIMULATE_MISSING_DETECTION}" == "1" ]]; then
  expected_rule_ids='[999999]'
fi

LOOKBACK_QUERY="now-${WAZUH_LOOKBACK_MINUTES}m"
ALERT_RESPONSE="$(curl -fsS -G "${WAZUH_URL%/}/alerts" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  --data-urlencode "sort=-timestamp" \
  --data-urlencode "limit=500" \
  --data-urlencode "q=timestamp>${LOOKBACK_QUERY}")"

missing_ids=()
for rule_id in $(echo "${expected_rule_ids}" | jq -r '.[]'); do
  matches="$(echo "${ALERT_RESPONSE}" | jq --arg rid "${rule_id}" '[.data.affected_items[]? | select((.rule.id|tostring)==$rid)] | length')"
  if [[ "${matches}" == "0" ]]; then
    missing_ids+=("${rule_id}")
  fi
done

status="success"
if (( ${#missing_ids[@]} > 0 )); then
  status="failure"
fi

jq -nc \
  --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg scenario_id "${SCENARIO_ID}" \
  --arg operation_id "${OPERATION_ID}" \
  --arg operation_state "${operation_state}" \
  --arg status "${status}" \
  --argjson expected_rule_ids "${expected_rule_ids}" \
  --argjson missing_rule_ids "$(printf '%s\n' "${missing_ids[@]:-}" | jq -R . | jq -s 'map(select(length > 0))')" \
  '{
    timestamp: $timestamp,
    scenario_id: $scenario_id,
    attack_execution: {
      operation_id: $operation_id,
      operation_state: $operation_state
    },
    detection_validation: {
      expected_rule_ids: $expected_rule_ids,
      missing_rule_ids: $missing_rule_ids,
      status: $status
    }
  }' > "${REPORT_FILE}"

cat "${REPORT_FILE}"

if [[ "${status}" != "success" ]]; then
  echo "Detection validation failed; missing alert rule IDs: ${missing_ids[*]}" >&2
  exit 1
fi

echo "Detection validation passed"
