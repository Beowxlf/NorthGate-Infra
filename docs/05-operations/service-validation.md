# Phase 2 Operational Service Validation

## 1. Purpose and Scope
This runbook defines the deterministic execution and validation sequence for Phase 2 Core Services Operationalization.

Validation scope:
1. Domain Controller + DNS functionality.
2. Wazuh manager + endpoint agent integration.
3. Endpoint telemetry workflow for Blue Team detection.
4. Full rerun idempotence after initial convergence.

Alignment references:
- Service catalog: `docs/02-infrastructure/service-catalog.md`
- Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
- Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Mandatory Execution Sequence
Execute every step in order. Downstream validation is invalid if any prior step fails.

1. `terraform destroy`
2. `terraform apply`
3. `ansible-playbook -i ansible/inventory/test-core/hosts.yml ansible/playbooks/phase_1_test_core.yml`
4. Re-run Ansible for idempotence:
   - `ansible-playbook -i ansible/inventory/test-core/hosts.yml ansible/playbooks/phase_1_test_core.yml`

## 3. Service Dependency Enforcement Model
Automation order in `phase_1_test_core.yml` is fixed:
1. Domain Controller bootstrap (`dc_bootstrap.yml`)
2. DNS and domain dependency validation (Linux + Windows checks)
3. Domain-dependent baseline Linux services (`common` role)
4. Wazuh manager deployment (`wazuh_deploy.yml`)
5. Wazuh agent enrollment and telemetry validation (`wazuh_agents.yml`)

## 4. Validation Procedures

### 4.1 Domain Validation
| Validation ID | Command / Check | Expected Result |
|---|---|---|
| DOM-01 | Linux `nslookup <domain>` from managed Linux nodes | Domain resolves using internal DNS. |
| DOM-02 | Linux `nslookup -type=SRV _ldap._tcp.dc._msdcs.<domain>` | SRV records return at least one DC endpoint. |
| DOM-03 | Windows `Resolve-DnsName <domain>` + `Test-NetConnection` to DC ports 389/88 | Host is domain-join capable. |
| DOM-04 | AD object validation on DC role execution | Test OU and test user exist and remain idempotent. |

### 4.2 Wazuh Validation
| Validation ID | Command / Check | Expected Result |
|---|---|---|
| WAZ-01 | Wazuh manager services + ports checks in role | Manager/indexer/dashboard active and listening. |
| WAZ-02 | `/var/ossec/bin/agent_control -ls` on manager | All expected Linux and Windows endpoints listed. |
| WAZ-03 | Linux endpoint emits `NORTHGATE_PHASE2_LINUX_ACTIVITY` log marker | Marker ingested in manager archives log. |
| WAZ-04 | Windows DC emits `NORTHGATE_PHASE2_WINDOWS_ACTIVITY` event marker | Marker ingested in manager archives log. |

### 4.3 System Validation
| Validation ID | Command / Check | Expected Result |
|---|---|---|
| SYS-01 | Ansible transport checks embedded in playbooks (`wait_for_connection`, WinRM, SSH) | All hosts reachable in scope. |
| SYS-02 | Service-state assertions in roles (`domain_controller`, `wazuh`) | Required services running after convergence. |
| SYS-03 | Second full Ansible run | `changed=0`, `failed=0`, `unreachable=0` for all hosts. |

## 5. Failure Scenarios and Expected Behavior

### 5.1 DC Unavailable
**Trigger:** DC offline or AD DS/DNS services unavailable.

Expected behavior:
1. DNS and domain validation tasks fail before Wazuh deployment.
2. Domain-dependent stages do not progress.
3. Automation exits with failure, preserving deterministic stop-on-dependency-failure semantics.

### 5.2 Wazuh Unavailable
**Trigger:** Wazuh manager services down, ports closed, or enrollment endpoint unavailable.

Expected behavior:
1. Manager validation fails in `wazuh` role.
2. Agent enrollment/registration checks fail in `wazuh_agents.yml`.
3. Telemetry marker ingestion checks fail within bounded retry window.

## 6. Blue Team Workflow (Minimal Operational Path)

### 6.1 Workflow Steps
1. Generate endpoint activity:
   - Linux endpoint: `logger -t phase2-validation NORTHGATE_PHASE2_LINUX_ACTIVITY`
   - Windows endpoint/DC: `eventcreate ... NORTHGATE_PHASE2_WINDOWS_ACTIVITY`
2. Confirm ingestion on Wazuh manager:
   - Search `/var/ossec/logs/archives/archives.log` for both markers.
3. Confirm endpoint registration:
   - `/var/ossec/bin/agent_control -ls`

### 6.2 Where Logs Appear and How to Query
- Raw ingested endpoint events: `/var/ossec/logs/archives/archives.log` on Wazuh manager.
- Agent status and registration: `/var/ossec/bin/agent_control -ls`.
- Dashboard confirmation path: Wazuh dashboard (`https://<wazuh-manager>`) for agent presence and event search.

## 7. Operational Completion Criteria
Phase 2 is complete when all are true:
1. Fresh rebuild (`destroy/apply`) completes without manual intervention.
2. `phase_1_test_core.yml` converges with all validation checks passing.
3. Linux endpoint and Windows DC telemetry are both visible in Wazuh ingestion evidence.
4. Second Ansible run is idempotent with no unintended changes.
5. The environment supports repeatable detection validation workflows for Blue Team operations.
