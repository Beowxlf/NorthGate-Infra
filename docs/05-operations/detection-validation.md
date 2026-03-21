# Phase 3 Detection Validation Workflow

## 1. Purpose
Define deterministic validation of the full attack-to-detection pipeline:
Caldera attack execution -> endpoint telemetry generation -> Wazuh alerting -> analyst verification.

Alignment references:
- Service catalog: `docs/02-infrastructure/service-catalog.md`
- Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
- Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Preconditions
1. Phase 2 services validated and operational.
2. Wazuh manager reachable and agents registered.
3. Caldera deployed by `ansible/playbooks/caldera_deploy.yml`.
4. Detection rules deployed from `detection/rules/wazuh_phase3_rules.xml`.

## 3. Validation Procedure

### 3.1 Attack Execution Steps
1. Launch Caldera operation `northgate-phase3-validation`.
2. Execute Linux process marker ability.
3. Execute Linux suspicious command marker ability.
4. Execute Windows credential access simulation ability.
5. Repeat the full operation a second time for consistency.

### 3.2 Expected Logs
| Step | Host Type | Expected Log Evidence |
|---|---|---|
| Linux process marker | Linux endpoint | `phase3-caldera process execution marker` in syslog/journald and Wazuh archives |
| Linux suspicious command | Linux endpoint | `phase3 suspicious command` plus command execution context |
| Windows credential simulation | Windows endpoint | Security Event ID 4625 and command execution artifact (`whoami`) |

### 3.3 Expected Wazuh Alerts
| Rule ID | Alert Intent | Trigger Source |
|---|---|---|
| 120001 | Linux process execution marker | Syslog message with `phase3-caldera` |
| 120002 | Linux suspicious command marker | Syslog message with `phase3 suspicious command` |
| 120003 | Windows failed authentication | Security Event ID 4625 |
| 120004 | Windows suspicious command line | Sysmon Event ID 1 with `whoami`/`net user`/`cmd.exe /c` |

### 3.4 Where to Verify Alerts
1. Wazuh dashboard -> Security events filter by rule IDs `120001-120004`.
2. Wazuh manager archives log:
   - `/var/ossec/logs/archives/archives.log`
3. Agent status on manager:
   - `/var/ossec/bin/agent_control -ls`

### 3.5 Pass/Fail Criteria
| Check | Pass Criteria | Fail Criteria |
|---|---|---|
| Caldera execution | Operation completes on scoped targets | Any stage fails or requires manual endpoint steps |
| Telemetry generation | Expected endpoint logs exist for each stage | Missing logs for one or more stages |
| Wazuh detection | Alerts generated for expected rule IDs | Any expected rule does not fire |
| Repeatability | Second run produces same alert classes | Inconsistent or non-deterministic alert behavior |

## 4. Deterministic Command Sequence (Operator Runbook)
1. Deploy Caldera:
   - `ansible-playbook -i ansible/inventory/test-core/hosts.yml ansible/playbooks/caldera_deploy.yml`
2. Confirm service reachability:
   - `curl -k https://<caldera-host>:8888 || curl http://<caldera-host>:8888`
3. Execute operation in Caldera UI/API using the Phase 3 ability set.
4. Validate alerts in Wazuh dashboard and archives log.
5. Re-run operation and compare alert presence/volume.

## 5. Evidence Capture Requirements
For each validation cycle, capture and store:
1. Caldera operation report (JSON or screenshot export).
2. Wazuh alert list filtered to rule IDs `120001-120004`.
3. Archives log excerpts proving source telemetry ingestion.
4. Final pass/fail record and timestamp.
