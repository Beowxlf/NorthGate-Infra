#!/usr/bin/env bash
set -euo pipefail

INVENTORY_PATH="${ANSIBLE_INVENTORY_PATH:-ansible/inventory/test-core/hosts.yml}"
PLAYBOOK_LIST="${ANSIBLE_DRIFT_PLAYBOOKS:-ansible/playbooks/phase_3_detection_platform.yml,ansible/playbooks/app_deploy.yml}"
REPORT_DIR="${VALIDATION_REPORT_DIR:-artifacts}"
REPORT_FILE="${REPORT_DIR}/drift-report.json"
SIMULATE_DRIFT="${SIMULATE_DRIFT:-0}"

mkdir -p "${REPORT_DIR}"

IFS=',' read -r -a playbooks <<< "${PLAYBOOK_LIST}"

changed_total=0
failed_total=0
playbook_reports=()

for playbook in "${playbooks[@]}"; do
  playbook="$(echo "${playbook}" | xargs)"
  if [[ ! -f "${playbook}" ]]; then
    echo "Drift check playbook not found: ${playbook}" >&2
    exit 1
  fi

  set +e
  output="$(ansible-playbook -i "${INVENTORY_PATH}" "${playbook}" --check --diff 2>&1)"
  rc=$?
  set -e

  recap_line="$(echo "${output}" | awk '/PLAY RECAP/{flag=1; next} flag && NF{line=$0} END{print line}')"
  changed="$(echo "${recap_line}" | sed -n 's/.*changed=\([0-9]\+\).*/\1/p')"
  failed="$(echo "${recap_line}" | sed -n 's/.*failed=\([0-9]\+\).*/\1/p')"

  changed="${changed:-0}"
  failed="${failed:-0}"

  if [[ ${rc} -ne 0 ]]; then
    failed=$((failed + 1))
  fi

  changed_total=$((changed_total + changed))
  failed_total=$((failed_total + failed))
  playbook_reports+=("$(jq -nc --arg playbook "${playbook}" --argjson changed "${changed}" --argjson failed "${failed}" '{playbook:$playbook, changed:$changed, failed:$failed}')")
done

if [[ "${SIMULATE_DRIFT}" == "1" ]]; then
  changed_total=$((changed_total + 1))
fi

status="success"
if [[ ${changed_total} -gt 0 || ${failed_total} -gt 0 ]]; then
  status="failure"
fi

printf '%s\n' "${playbook_reports[@]}" | jq -s \
  --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg status "${status}" \
  --argjson changed_total "${changed_total}" \
  --argjson failed_total "${failed_total}" \
  '{
    timestamp: $timestamp,
    status: $status,
    drift_definition: {
      manual_changes: "Any host-side mutation not represented in Ansible roles/vars.",
      config_mismatch: "Any --check run reporting changed>0 against declared desired state."
    },
    summary: {
      changed_total: $changed_total,
      failed_total: $failed_total
    },
    playbooks: .
  }' > "${REPORT_FILE}"

cat "${REPORT_FILE}"

if [[ "${status}" != "success" ]]; then
  echo "Drift detected (changed_total=${changed_total}, failed_total=${failed_total})" >&2
  exit 1
fi

echo "No configuration drift detected"
