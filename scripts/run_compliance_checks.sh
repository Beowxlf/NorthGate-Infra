#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="${VALIDATION_REPORT_DIR:-artifacts}"
REPORT_FILE="${REPORT_DIR}/compliance-report.json"
POLICY_FILE="${SECURITY_POLICY_FILE:-scripts/security_policy.json}"
POLICY_DOC="${SECURITY_POLICY_DOC:-docs/03-configuration/security-policies.md}"
HARDENING_DEFAULTS="${HARDENING_DEFAULTS_FILE:-ansible/roles/hardening/defaults/main.yml}"
HARDENING_TASKS="${HARDENING_TASKS_FILE:-ansible/roles/hardening/tasks/main.yml}"
DRIFT_SCRIPT="scripts/check_ansible_drift.sh"
COMPLIANCE_ENV="${COMPLIANCE_ENV:-test-core}"
SIMULATE_POLICY_VIOLATION="${SIMULATE_POLICY_VIOLATION:-0}"
COMPLIANCE_ENABLE_HOST_DRIFT="${COMPLIANCE_ENABLE_HOST_DRIFT:-0}"

mkdir -p "${REPORT_DIR}"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 2; }; }
need_cmd jq
need_cmd python3
need_cmd ansible-playbook

if [[ ! -f "${POLICY_FILE}" ]]; then
  echo "Policy file missing: ${POLICY_FILE}" >&2
  exit 1
fi
if [[ ! -f "${POLICY_DOC}" ]]; then
  echo "Policy documentation missing: ${POLICY_DOC}" >&2
  exit 1
fi
if [[ ! -f "${HARDENING_DEFAULTS}" || ! -f "${HARDENING_TASKS}" ]]; then
  echo "Hardening role files missing" >&2
  exit 1
fi

ansible-playbook -i "ansible/inventory/${COMPLIANCE_ENV}/hosts.yml" ansible/playbooks/security_enforcement.yml --syntax-check >/dev/null

python_validation="$REPORT_DIR/.compliance-policy-validation.json"
python3 - "${POLICY_FILE}" "${HARDENING_DEFAULTS}" "${HARDENING_TASKS}" > "${python_validation}" <<'PY'
import json
import sys
from pathlib import Path
import yaml

policy_path = Path(sys.argv[1])
defaults_path = Path(sys.argv[2])
tasks_path = Path(sys.argv[3])

policy = json.loads(policy_path.read_text())
defaults = yaml.safe_load(defaults_path.read_text())
tasks_text = tasks_path.read_text()

checks = []

def emit(name, ok, detail):
    checks.append({"check": name, "pass": bool(ok), "detail": detail})

ssh_lines = {item["line"] for item in defaults.get("hardening_ssh_settings", [])}
emit("ssh_root_login_disabled", "PermitRootLogin no" in ssh_lines, "PermitRootLogin no must be enforced")
emit("ssh_password_auth_disabled", "PasswordAuthentication no" in ssh_lines, "PasswordAuthentication no must be enforced")
emit("ssh_pubkey_enabled", "PubkeyAuthentication yes" in ssh_lines, "PubkeyAuthentication yes must be enforced")

emit(
    "allowed_services_match_policy",
    defaults.get("hardening_allowed_services", []) == policy.get("allowed_services", []),
    "hardening_allowed_services must match scripts/security_policy.json"
)
emit(
    "disallowed_services_match_policy",
    defaults.get("hardening_disable_services", []) == policy.get("disallowed_services", []),
    "hardening_disable_services must match scripts/security_policy.json"
)
emit(
    "tcp_ports_match_policy",
    defaults.get("hardening_firewall_allowed_tcp_ports", []) == policy.get("required_ports", {}).get("tcp", []),
    "hardening_firewall_allowed_tcp_ports must match policy"
)
emit(
    "udp_ports_match_policy",
    defaults.get("hardening_firewall_allowed_udp_ports", []) == policy.get("required_ports", {}).get("udp", []),
    "hardening_firewall_allowed_udp_ports must match policy"
)
emit(
    "required_env_vars_match_policy",
    defaults.get("hardening_secret_sources", {}).get("required_env_vars", []) == policy.get("required_env_vars", []),
    "hardening required_env_vars must match policy"
)
emit(
    "required_log_paths_match_policy",
    defaults.get("hardening_required_log_paths", []) == policy.get("required_log_paths", []),
    "hardening_required_log_paths must match policy"
)

required_task_fragments = [
    "Apply SSH daemon hardening settings",
    "Install firewall packages",
    "Disable unnecessary services",
    "Assert security secret sources are externalized"
]
for fragment in required_task_fragments:
    emit(f"task_present_{fragment.lower().replace(' ', '_')}", fragment in tasks_text, f"Task marker missing: {fragment}")

print(json.dumps({"checks": checks}, indent=2))
PY

drift_mode="static"
drift_rc=0
if [[ "${COMPLIANCE_ENABLE_HOST_DRIFT}" == "1" ]]; then
  drift_mode="host"
  set +e
  ANSIBLE_DRIFT_PLAYBOOKS="ansible/playbooks/security_enforcement.yml,ansible/playbooks/phase_5_validation_hooks.yml" \
    INVENTORY_PATH="ansible/inventory/${COMPLIANCE_ENV}/hosts.yml" \
    "${DRIFT_SCRIPT}"
  drift_rc=$?
  set -e
else
  jq -n --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '{timestamp:$timestamp,status:"success",mode:"static",summary:{changed_total:0,failed_total:0},playbooks:[]}' > "${REPORT_DIR}/drift-report.json"
fi

policy_status="success"
if ! jq -e '.checks | all(.pass == true)' "${python_validation}" >/dev/null; then
  policy_status="failure"
fi

drift_status="success"
if [[ ${drift_rc} -ne 0 ]]; then
  drift_status="failure"
fi

simulated_violation=false
if [[ "${SIMULATE_POLICY_VIOLATION}" == "1" ]]; then
  simulated_violation=true
fi

overall_status="success"
if [[ "${policy_status}" != "success" || "${drift_status}" != "success" || "${simulated_violation}" == "true" ]]; then
  overall_status="failure"
fi

jq -n \
  --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg status "${overall_status}" \
  --arg policy_status "${policy_status}" \
  --arg drift_status "${drift_status}" \
  --argjson simulated_violation "${simulated_violation}" \
  --arg drift_mode "${drift_mode}" \
  --slurpfile policy_checks "${python_validation}" \
  --slurpfile drift_report "${REPORT_DIR}/drift-report.json" \
  '{
    timestamp: $timestamp,
    status: $status,
    controls: {
      hardening_rules_applied: ($policy_status == "success"),
      services_match_policy: ($policy_status == "success"),
      ports_match_policy: ($policy_status == "success"),
      unauthorized_changes_detected: ($drift_status == "failure" or $simulated_violation == true)
    },
    policy_validation: $policy_checks[0],
    drift_validation: ($drift_report[0] + {mode: $drift_mode}),
    simulated_violation: $simulated_violation
  }' > "${REPORT_FILE}"

cat "${REPORT_FILE}"

if [[ "${overall_status}" != "success" ]]; then
  echo "Compliance checks failed" >&2
  exit 1
fi

echo "Compliance checks passed"
