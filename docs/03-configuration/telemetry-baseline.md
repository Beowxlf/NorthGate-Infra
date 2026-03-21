# Phase 3 Telemetry Baseline (Blue Team Signal-to-Noise Control)

## 1. Purpose
This baseline defines deterministic "normal" telemetry for NorthGate-Infra so detection content can distinguish routine operations from adversary simulation events.

Alignment references:
- Service catalog: `docs/02-infrastructure/service-catalog.md`
- Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
- Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Baseline Scope
| Environment | Systems in Scope | Baseline Objective |
|---|---|---|
| `test-core` | Domain controllers, Wazuh manager, log pipeline nodes | Validate identity and monitoring platform noise floor |
| `workbench` | Caldera server (control plane host in current phase) | Validate attack orchestration events |
| `app-hosting` | UNKNOWN | Reserved for future application telemetry profile |

## 3. Normal Activity Baseline

### 3.1 Login Baseline Events
| Platform | Source | Event Pattern | Expected Frequency | Baseline Interpretation |
|---|---|---|---|---|
| Windows domain controllers/endpoints | Security log | Event ID 4624 (successful logon) | Regular during administrative sessions and scheduled tasks | Normal identity usage |
| Windows domain controllers/endpoints | Security log | Event ID 4634/4647 (logoff) | Follows interactive/admin sessions | Normal session closure |
| Linux endpoints | `auth.log` / journald | `Accepted publickey` or `session opened` | During automation and controlled operator access | Normal managed access |

### 3.2 System Process Baseline Events
| Platform | Source | Event Pattern | Expected Frequency | Baseline Interpretation |
|---|---|---|---|---|
| Linux endpoints | syslog/journald | `systemd` service start/stop for approved services | During deployment or reboot windows | Expected lifecycle transition |
| Linux endpoints | syslog/journald | `CRON` / timer execution events | Periodic | Expected maintenance automation |
| Windows endpoints | Sysmon Event ID 1 | `svchost.exe`, `services.exe`, approved management tooling | Continuous | Normal service/process activity |

### 3.3 Network Activity Baseline Events
| Source System | Log Source | Pattern | Baseline Interpretation |
|---|---|---|---|
| Endpoints across zones | Wazuh agent + manager archives | Outbound DNS to internal resolvers | Required service discovery |
| Endpoints across zones | Wazuh agent + manager archives | Agent-to-manager traffic (1514/1515) | Required telemetry forwarding |
| Management/workbench hosts | System logs + Wazuh archives | SSH/WinRM to managed nodes during playbook runs | Normal control-plane behavior |

## 4. Baseline Windows for Validation
1. Pre-change baseline collection window: minimum 30 minutes of normal operation.
2. Attack validation window: bounded 10-minute exercise with only declared scenario actions.
3. Post-exercise cooldown: 15 minutes to confirm alert cessation and no persistent anomalous noise.

## 5. Signal Classification Contract
| Classification | Criteria | Action |
|---|---|---|
| Baseline noise | Matches expected event IDs/process patterns above and occurs in expected windows | Do not escalate; retain for trend analysis |
| Validation signal | Matches declared Phase 3 markers/commands and mapped detection rules | Escalate to test incident queue; verify detection quality |
| Unknown deviation | Not mapped to baseline or simulation profile | Mark as `UNKNOWN`, triage immediately, and update baseline if benign |

## 6. Reproducibility Requirements
1. Baseline review must be executed before every detection rule change promotion.
2. Any added baseline event class must be documented in this file within the same change set.
3. Baseline and detection rules must be versioned together to keep deterministic interpretation.
