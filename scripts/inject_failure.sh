#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-inject}"
SCENARIO="${2:-}"
TARGET_HOST="${3:-}"
DURATION_SECONDS="${4:-0}"

SSH_USER="${FAILURE_SSH_USER:-}"
SSH_KEY_PATH="${FAILURE_SSH_KEY_PATH:-}"
SSH_PORT="${FAILURE_SSH_PORT:-22}"
ORCHESTRATOR_SOURCE_IP="${ORCHESTRATOR_SOURCE_IP:-}"
STATE_DIR="${FAILURE_STATE_DIR:-artifacts/failure-state}"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 2; }; }
need_cmd ssh
need_cmd date

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") inject <scenario> <target_host> [duration_seconds]
  $(basename "$0") recover <scenario> <target_host>

Scenarios:
  dc_failure
  dns_failure
  wazuh_manager_failure
  endpoint_failure
  application_failure

Environment variables:
  FAILURE_SSH_USER            Required. SSH user for remote host.
  FAILURE_SSH_KEY_PATH        Optional. SSH private key path.
  FAILURE_SSH_PORT            Optional. SSH port (default: 22).
  ORCHESTRATOR_SOURCE_IP      Optional. Required for dc_failure with METHOD=isolate.
  FAILURE_METHOD              Optional. service_stop|isolate (dc_failure only; default: service_stop).
  FAILURE_STATE_DIR           Optional. State directory (default: artifacts/failure-state).
USAGE
}

if [[ -z "${SCENARIO}" || -z "${TARGET_HOST}" ]]; then
  usage
  exit 1
fi

if [[ -z "${SSH_USER}" ]]; then
  echo "FAILURE_SSH_USER is required" >&2
  exit 1
fi

mkdir -p "${STATE_DIR}"
state_file="${STATE_DIR}/${SCENARIO}_${TARGET_HOST}.env"

ssh_opts=(-p "${SSH_PORT}" -o BatchMode=yes -o StrictHostKeyChecking=no)
if [[ -n "${SSH_KEY_PATH}" ]]; then
  ssh_opts+=( -i "${SSH_KEY_PATH}" )
fi

remote_exec() {
  ssh "${ssh_opts[@]}" "${SSH_USER}@${TARGET_HOST}" "$@"
}

write_state() {
  local key="$1" value="$2"
  if [[ ! -f "${state_file}" ]]; then
    : > "${state_file}"
  fi
  if grep -qE "^${key}=" "${state_file}"; then
    sed -i "s|^${key}=.*$|${key}=${value}|" "${state_file}"
  else
    echo "${key}=${value}" >> "${state_file}"
  fi
}

read_state() {
  local key="$1"
  if [[ ! -f "${state_file}" ]]; then
    return 1
  fi
  grep -E "^${key}=" "${state_file}" | tail -n1 | cut -d'=' -f2-
}

service_for_scenario() {
  case "${SCENARIO}" in
    dc_failure) echo "samba-ad-dc" ;;
    dns_failure) echo "named" ;;
    wazuh_manager_failure) echo "wazuh-manager" ;;
    endpoint_failure) echo "wazuh-agent" ;;
    application_failure) echo "scrambleiq" ;;
    *)
      echo "Unsupported scenario: ${SCENARIO}" >&2
      exit 1
      ;;
  esac
}

ensure_service_exists() {
  local service="$1"
  if ! remote_exec "systemctl list-unit-files | awk '{print \$1}' | grep -Fxq '${service}.service'"; then
    echo "Service ${service}.service not present on ${TARGET_HOST}" >&2
    exit 1
  fi
}

inject_service_stop() {
  local service="$1"
  ensure_service_exists "${service}"
  local was_active
  was_active="$(remote_exec "systemctl is-active ${service} >/dev/null 2>&1 && echo 1 || echo 0")"
  write_state REMOTE_ACTION "service_stop"
  write_state SERVICE_NAME "${service}"
  write_state SERVICE_WAS_ACTIVE "${was_active}"
  write_state INJECTED_AT "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  remote_exec "sudo systemctl stop ${service}"
}

recover_service_stop() {
  local service was_active
  service="$(read_state SERVICE_NAME || true)"
  was_active="$(read_state SERVICE_WAS_ACTIVE || true)"

  if [[ -z "${service}" ]]; then
    echo "No service state found in ${state_file}" >&2
    exit 1
  fi

  if [[ "${was_active}" == "1" ]]; then
    remote_exec "sudo systemctl start ${service}"
  fi
}

inject_dc_isolation() {
  if [[ -z "${ORCHESTRATOR_SOURCE_IP}" ]]; then
    echo "ORCHESTRATOR_SOURCE_IP is required for dc_failure isolation mode" >&2
    exit 1
  fi

  write_state REMOTE_ACTION "network_isolate"
  write_state ISOLATION_SOURCE_IP "${ORCHESTRATOR_SOURCE_IP}"
  write_state INJECTED_AT "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  remote_exec "sudo iptables -I INPUT -s ${ORCHESTRATOR_SOURCE_IP}/32 -p tcp --dport ${SSH_PORT} -j ACCEPT"
  remote_exec "sudo iptables -I INPUT -j DROP"
  remote_exec "sudo iptables -I OUTPUT -j DROP"
}

recover_dc_isolation() {
  remote_exec "sudo iptables -D OUTPUT -j DROP || true"
  remote_exec "sudo iptables -D INPUT -j DROP || true"
  remote_exec "sudo iptables -D INPUT -s $(read_state ISOLATION_SOURCE_IP)/32 -p tcp --dport ${SSH_PORT} -j ACCEPT || true"
}

inject() {
  local method="${FAILURE_METHOD:-service_stop}"
  if [[ "${SCENARIO}" == "dc_failure" && "${method}" == "isolate" ]]; then
    inject_dc_isolation
  else
    inject_service_stop "$(service_for_scenario)"
  fi

  write_state TARGET_HOST "${TARGET_HOST}"
  write_state SCENARIO "${SCENARIO}"
  write_state DURATION_SECONDS "${DURATION_SECONDS}"

  if [[ "${DURATION_SECONDS}" =~ ^[0-9]+$ ]] && (( DURATION_SECONDS > 0 )); then
    sleep "${DURATION_SECONDS}"
    recover
  fi
}

recover() {
  local action
  action="$(read_state REMOTE_ACTION || true)"
  case "${action}" in
    service_stop)
      recover_service_stop
      ;;
    network_isolate)
      recover_dc_isolation
      ;;
    "")
      echo "No recovery action recorded for ${SCENARIO} on ${TARGET_HOST}" >&2
      exit 1
      ;;
    *)
      echo "Unsupported recovery action in state file: ${action}" >&2
      exit 1
      ;;
  esac

  write_state RECOVERED_AT "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

case "${ACTION}" in
  inject)
    inject
    ;;
  recover)
    recover
    ;;
  *)
    usage
    exit 1
    ;;
esac

echo "${ACTION} completed for scenario=${SCENARIO} target_host=${TARGET_HOST}"
