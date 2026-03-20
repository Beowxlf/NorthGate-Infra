# Phase 2 Service Validation Framework

## 1. Purpose
This document defines deterministic validation and verification gates for Phase 2 operations across foundational and dependent services.

Validation outputs are designed to confirm:
1. Foundational core services are reachable and functional.
2. Monitoring/detection data paths are active.
3. The automation control plane can enforce configuration state.
4. Provisioned infrastructure matches declared inventory.
5. Configuration management remains idempotent on rerun.

## 2. Scope and Alignment

| Reference Artifact | Alignment Requirement | Validation Impact |
|---|---|---|
| `docs/02-infrastructure/service-catalog.md` | Service intent and environment placement for Domain Controller, DNS, Wazuh, and Control Node dependencies. | Defines what must be validated by service and environment. |
| `docs/01-architecture/environment-model.md` | `test-core` hosts Domain Controller, DNS, Wazuh; `workbench` hosts Control Node; promotion sequence flows through `test-core` first. | Defines where each validation procedure must execute. |
| `docs/01-architecture/service-dependency-model.md` | DNS/time/identity dependencies and telemetry flow requirements across trust zones. | Defines dependency order and failure interpretation. |

## 3. Validation Execution Model

### 3.1 Inputs (Required)
| Input | Source | Expected State |
|---|---|---|
| Terraform state for Phase 2 target | `terraform/` workflow output | Apply completed without unresolved errors. |
| Ansible inventory for target environment(s) | `ansible/` inventory | Hostnames/IPs match provisioned infrastructure. |
| Domain details | Environment vars or Ansible vars | `AD_DOMAIN_FQDN` is set and non-empty. |
| Wazuh manager endpoint | Environment vars or Ansible vars | `WAZUH_MANAGER_HOST` is set and reachable. |
| Control node credentials/keys | Secrets management process | Control node can authenticate to managed hosts. |

### 3.2 Sequencing (Mandatory)
1. Validate Infrastructure provisioning.
2. Validate Domain Controller and DNS.
3. Validate Wazuh connectivity and ingestion.
4. Validate Control Node orchestration reachability.
5. Validate Ansible idempotence.

No step may be skipped. Downstream checks are invalid when an upstream step fails.

### 3.3 Result States
| State | Meaning | Gate Decision |
|---|---|---|
| `PASS` | All checks in a section meet expected output. | Proceed to next section. |
| `FAIL` | One or more required checks do not meet expected output. | Stop; remediate and rerun from failed section. |
| `BLOCKED` | Required input unavailable (for example, missing variable, credential, or host access). | Stop; restore prerequisites and rerun. |

## 4. Validation Checklist

| ID | Area | Validation Item | Environment | Expected Result |
|---|---|---|---|---|
| INF-01 | Infrastructure | All expected VMs exist and are powered on. | `test-core`, `workbench`, `app-hosting` as applicable | Hypervisor/API inventory matches Terraform output. |
| INF-02 | Infrastructure | VM network assignment and IP addressing match declared model. | Same as INF-01 | Hostname/IP mapping matches inventory and environment definitions. |
| DC-01 | Domain Controller | Domain is reachable from managed hosts. | `test-core`, consumers in other envs | Domain discovery query returns domain controller(s). |
| DNS-01 | Domain Controller / DNS | Internal DNS resolves required service records. | All participating envs | Forward lookup succeeds for core service hostnames. |
| WAZ-01 | Wazuh | Agents are connected to Wazuh manager. | All agent-hosting envs | Agent status is active/connected. |
| WAZ-02 | Wazuh | Log events are ingested and queryable. | `test-core` monitoring stack | Test event appears in Wazuh within defined SLA. |
| CTRL-01 | Control Node | Control node can execute Ansible successfully. | `workbench` | `ansible --version` and ad-hoc module run succeed. |
| CTRL-02 | Control Node | Control node can reach all managed hosts via Ansible transport. | All managed envs | `ansible all -m ping` returns success for all in-scope hosts. |
| IDEMP-01 | Idempotence | Re-running configuration yields no changes. | All configured envs | Second `ansible-playbook` run reports `changed=0` for all hosts. |

## 5. Test Procedures

### 5.1 Infrastructure Validation Procedures

### Procedure INF-01: VM Provisioning Verification
**Objective:** Confirm expected VM footprint is provisioned correctly.

**Steps:**
1. From IaC execution context, generate Terraform state inventory:
   - `terraform state list`
2. Collect runtime VM inventory from provider/hypervisor API (`UNKNOWN`: provider-specific command).
3. Compare expected VM identifiers against runtime inventory.
4. Confirm each expected VM is in `running`/`poweredOn` state.

**Pass Criteria:**
- All expected VM resources exist in Terraform state and runtime inventory.
- No expected VM is absent or stopped.

### Procedure INF-02: Network and Address Verification
**Objective:** Confirm VM addressing and segmentation match declared environment model.

**Steps:**
1. Export host/IP assignments from Ansible inventory:
   - `ansible-inventory -i <inventory_file> --list`
2. On each host, validate primary IP and hostname association (`UNKNOWN`: command differs by OS baseline).
3. Validate that control node can resolve each managed hostname:
   - `getent hosts <hostname>` or `nslookup <hostname>`
4. Record mismatches by host.

**Pass Criteria:**
- Hostname/IP mapping is consistent across Terraform outputs, runtime host state, and Ansible inventory.

### 5.2 Domain Controller and DNS Procedures

### Procedure DC-01: Domain Reachability
**Objective:** Confirm domain is reachable and discoverable from managed systems.

**Steps:**
1. On one domain-joined Windows host, run:
   - `nltest /dsgetdc:<AD_DOMAIN_FQDN>`
2. On Linux control node (or Linux managed host), run DNS SRV query:
   - `dig +short _ldap._tcp.dc._msdcs.<AD_DOMAIN_FQDN> SRV`
3. Verify at least one Domain Controller is returned.

**Pass Criteria:**
- Windows and/or Linux discovery commands return at least one valid DC endpoint.

### Procedure DNS-01: DNS Resolution
**Objective:** Confirm internal DNS resolves core service hostnames.

**Steps:**
1. Build required hostname list: DC(s), Wazuh manager, control node, representative app host(s).
2. For each hostname, run from control node:
   - `nslookup <hostname>`
3. For each hostname, run reverse lookup where PTR records are expected:
   - `nslookup <ip_address>`
4. Record lookup latency and failures.

**Pass Criteria:**
- Forward lookups succeed for all required hostnames.
- Reverse lookups succeed where PTR records are part of baseline.

### 5.3 Wazuh Procedures

### Procedure WAZ-01: Agent Connection Validation
**Objective:** Confirm Wazuh agents are connected.

**Steps:**
1. On Wazuh manager node, list agents:
   - `/var/ossec/bin/agent_control -ls`
2. Filter for disconnected or never connected states.
3. Cross-check against expected managed host inventory.

**Pass Criteria:**
- All expected enrolled agents are present and in active/connected state.

### Procedure WAZ-02: Log Ingestion Validation
**Objective:** Confirm logs are ingested end-to-end.

**Steps:**
1. Select a managed test host with Wazuh agent.
2. Generate a deterministic test event:
   - Linux example: `logger -t phase2-validation "WAZUH_TEST_EVENT_$(date +%s)"`
   - Windows example: `eventcreate /T INFORMATION /ID 100 /L APPLICATION /SO Phase2Validation /D "WAZUH_TEST_EVENT"`
3. In Wazuh, query for the unique event marker (`UNKNOWN`: dashboard/API query command based on deployment method).
4. Confirm event appears within ingest SLA (recommended: 120 seconds).

**Pass Criteria:**
- Test event is visible in Wazuh with correct source host metadata.

### 5.4 Control Node Procedures

### Procedure CTRL-01: Ansible Runtime Validation
**Objective:** Confirm control node can execute Ansible tooling.

**Steps:**
1. On control node, run:
   - `ansible --version`
2. Confirm expected Python and module paths are available:
   - `ansible-config dump --only-changed`
3. Validate inventory parsing:
   - `ansible-inventory -i <inventory_file> --graph`

**Pass Criteria:**
- All commands return exit code 0.
- Inventory renders without parse errors.

### Procedure CTRL-02: Reachability to All Hosts
**Objective:** Confirm control node can reach all managed hosts over Ansible transport.

**Steps:**
1. Execute connectivity test:
   - `ansible all -i <inventory_file> -m ping`
2. Capture unreachable/failed host list.
3. For each failed host, verify DNS resolution and network path (`UNKNOWN`: traceroute tooling differs by OS and policy).

**Pass Criteria:**
- No hosts report `UNREACHABLE` or module execution failure.

### 5.5 Idempotence Procedure

### Procedure IDEMP-01: Configuration Re-Run Idempotence
**Objective:** Ensure configuration application converges with no further changes on rerun.

**Steps:**
1. Execute baseline configuration run:
   - `ansible-playbook -i <inventory_file> <playbook>.yml`
2. Immediately execute the same playbook with identical inputs:
   - `ansible-playbook -i <inventory_file> <playbook>.yml`
3. Parse recap output for each host.
4. Validate `changed=0` on second run for all in-scope hosts.

**Pass Criteria:**
- Second run reports `failed=0`, `unreachable=0`, and `changed=0` for every managed host.

## 6. Failure Indicators and Triage Signals

| Area | Failure Indicator | Likely Cause Domain | Immediate Action |
|---|---|---|---|
| Infrastructure | Expected VM missing from runtime inventory | Terraform apply incomplete, provider/API failure, state drift | Reconcile Terraform state vs provider inventory; rerun apply after drift correction. |
| Infrastructure | VM present but wrong network/IP | Incorrect variable set, template mismatch, DHCP/static conflict | Validate environment variable files and network definitions; reprovision if needed. |
| Domain Controller | `nltest`/SRV lookup returns no DC | DC service down, DNS SRV missing, firewall segmentation issue | Validate DC service health and SRV records; check zone ACL/firewall for LDAP/Kerberos/DNS. |
| DNS | Hostname lookup timeout/NXDOMAIN | DNS zone misconfiguration, stale record, resolver path blocked | Verify zone records and client resolver configuration; flush/update records. |
| Wazuh | Agent shows disconnected | Agent service stopped, key enrollment issue, manager unreachable | Restart agent, re-enroll key if required, verify manager route and port access. |
| Wazuh | Test log not ingested in SLA | Pipeline backlog, decoder/index issue, transport interruption | Check manager/indexer health and queue depth; inspect agent logs and pipeline errors. |
| Control Node | `ansible --version` fails | Missing runtime dependencies, broken Python environment | Reinstall/repair Ansible runtime and pinned dependencies. |
| Control Node | `ansible ping` unreachable hosts | SSH/WinRM auth failure, DNS/network issue, host down | Validate credentials, host status, resolver output, and ACL paths. |
| Idempotence | Second run reports `changed>0` | Non-idempotent tasks, dynamic artifacts, unmanaged drift | Identify changed tasks, add `creates`/`unless`/state guards, and eliminate mutable side effects. |
| Idempotence | Second run has failures | Sequencing race, dependency not ready, fragile task ordering | Add explicit dependency waits/health checks and deterministic ordering constraints. |

## 7. Validation Evidence Recording (Required)
For each validation execution, record the following artifacts under change-control evidence:
1. Timestamped command transcript.
2. Tool outputs for each checklist ID.
3. Failed host/service list (if any).
4. Remediation actions taken.
5. Final rerun results showing `PASS` or unresolved `FAIL/BLOCKED` state.

If any required artifact is missing, validation status is `BLOCKED`.
