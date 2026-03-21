#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="${VALIDATION_REPORT_DIR:-artifacts}"
REPORT_FILE="${REPORT_DIR}/system-integrity-report.json"

DOMAIN_URL="${DOMAIN_URL:?DOMAIN_URL is required}"
DNS_QUERY_NAME="${DNS_QUERY_NAME:?DNS_QUERY_NAME is required}"
SCRAMBLEIQ_URL="${SCRAMBLEIQ_URL:?SCRAMBLEIQ_URL is required}"
SCRAMBLEIQ_HEALTH_PATH="${SCRAMBLEIQ_HEALTH_PATH:-/api/health}"
SCRAMBLEIQ_API_KEY="${SCRAMBLEIQ_API_KEY:-}"
WAZUH_URL="${WAZUH_URL:?WAZUH_URL is required}"
WAZUH_USERNAME="${WAZUH_USERNAME:?WAZUH_USERNAME is required}"
WAZUH_PASSWORD="${WAZUH_PASSWORD:?WAZUH_PASSWORD is required}"
EXPECTED_WAZUH_AGENTS="${EXPECTED_WAZUH_AGENTS:?EXPECTED_WAZUH_AGENTS is required}"
SIMULATE_SERVICE_DOWN="${SIMULATE_SERVICE_DOWN:-0}"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 2; }; }
need_cmd curl
need_cmd jq
need_cmd getent

mkdir -p "${REPORT_DIR}"

domain_ok=0
dns_ok=0
wazuh_ok=0
scrambleiq_ok=0

if curl -fsS --max-time 15 "${DOMAIN_URL}" >/dev/null; then
  domain_ok=1
fi

if getent hosts "${DNS_QUERY_NAME}" >/dev/null; then
  dns_ok=1
fi

if [[ "${SIMULATE_SERVICE_DOWN}" == "1" ]]; then
  scrambleiq_ok=0
else
  if [[ -n "${SCRAMBLEIQ_API_KEY}" ]]; then
    if curl -fsS --max-time 15 -H "x-api-key: ${SCRAMBLEIQ_API_KEY}" "${SCRAMBLEIQ_URL%/}${SCRAMBLEIQ_HEALTH_PATH}" >/dev/null; then
      scrambleiq_ok=1
    fi
  else
    if curl -fsS --max-time 15 "${SCRAMBLEIQ_URL%/}${SCRAMBLEIQ_HEALTH_PATH}" >/dev/null; then
      scrambleiq_ok=1
    fi
  fi
fi

token="$(curl -fsS -u "${WAZUH_USERNAME}:${WAZUH_PASSWORD}" -X POST "${WAZUH_URL%/}/security/user/authenticate?raw=true")"
active_agents="$(curl -fsS -G "${WAZUH_URL%/}/agents" -H "Authorization: Bearer ${token}" --data-urlencode 'status=active' --data-urlencode 'limit=500' | jq '.data.total_affected_items')"
if [[ "${active_agents}" -ge "${EXPECTED_WAZUH_AGENTS}" ]]; then
  wazuh_ok=1
fi

overall_status="success"
if [[ ${domain_ok} -ne 1 || ${dns_ok} -ne 1 || ${wazuh_ok} -ne 1 || ${scrambleiq_ok} -ne 1 ]]; then
  overall_status="failure"
fi

jq -nc \
  --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg status "${overall_status}" \
  --arg domain_url "${DOMAIN_URL}" \
  --arg dns_query_name "${DNS_QUERY_NAME}" \
  --arg scrambleiq_url "${SCRAMBLEIQ_URL%/}${SCRAMBLEIQ_HEALTH_PATH}" \
  --argjson expected_wazuh_agents "${EXPECTED_WAZUH_AGENTS}" \
  --argjson active_wazuh_agents "${active_agents}" \
  --argjson domain_ok "${domain_ok}" \
  --argjson dns_ok "${dns_ok}" \
  --argjson scrambleiq_ok "${scrambleiq_ok}" \
  --argjson wazuh_ok "${wazuh_ok}" \
  '{
    timestamp: $timestamp,
    status: $status,
    checks: {
      domain_reachable: {target: $domain_url, pass: ($domain_ok == 1)},
      dns_resolution: {target: $dns_query_name, pass: ($dns_ok == 1)},
      scrambleiq_reachable: {target: $scrambleiq_url, pass: ($scrambleiq_ok == 1)},
      wazuh_agents_connected: {
        expected_minimum: $expected_wazuh_agents,
        observed_active: $active_wazuh_agents,
        pass: ($wazuh_ok == 1)
      }
    }
  }' > "${REPORT_FILE}"

cat "${REPORT_FILE}"

if [[ "${overall_status}" != "success" ]]; then
  echo "System integrity checks failed" >&2
  exit 1
fi

echo "System integrity checks passed"
