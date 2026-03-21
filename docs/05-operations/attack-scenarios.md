# Phase 3 Attack Scenarios (Caldera-Originated)

## 1. Purpose
This runbook defines deterministic adversary simulation workflows launched from MITRE Caldera against endpoint targets to validate Blue Team detections in Wazuh.

Alignment references:
- Service catalog: `docs/02-infrastructure/service-catalog.md`
- Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
- Dependency model: `docs/01-architecture/service-dependency-model.md`

## 2. Scenario Definition

### Scenario ID: `PH3-ATK-001`
**Name:** Process + Command + Credential Access Simulation

| Attribute | Value |
|---|---|
| Origin zone | Workbench / Adversary Simulation Zone |
| Origin service | MITRE Caldera server |
| Target zones | User / Endpoint Zone (primary), Core Services Zone endpoint telemetry (limited validation on DC) |
| Targets | Hosts in `os_linux` and `os_windows` (excluding Wazuh manager for attack execution) |
| Objective | Generate repeatable telemetry for execution and authentication detections |

## 3. Attack Chain (Deterministic Sequence)

### Step 1 — Linux Process Execution Marker
- Technique: T1059.004 (Unix Shell)
- Action (via Caldera ability):
  - `logger -t phase3-caldera "phase3-caldera process execution marker"`
- Expected telemetry:
  - Syslog entry on Linux endpoint.
  - Wazuh archive ingestion on manager.

### Step 2 — Linux Suspicious Command Marker
- Technique: T1059.004 (Unix Shell)
- Action (via Caldera ability):
  - `logger -t phase3-caldera "phase3 suspicious command: whoami && id"`
  - `whoami`
  - `id`
- Expected telemetry:
  - Command execution marker and process context in endpoint logs.
  - Wazuh rule hit for suspicious command marker.

### Step 3 — Windows Credential Access Simulation (Basic)
- Technique: T1110 (Brute Force simulation pattern)
- Action (via Caldera ability):
  - Trigger failed authentication activity (Security Event ID 4625) using controlled invalid authentication attempt.
  - Execute `cmd.exe /c whoami` as process execution artifact.
- Expected telemetry:
  - Windows authentication failure events.
  - Optional Sysmon process event (if Sysmon policy active).
  - Wazuh rule hits for authentication failure and suspicious command line.

## 4. Caldera Operation Workflow
1. Deploy Caldera with `ansible/playbooks/caldera_deploy.yml`.
2. Import or define operation profile using `caldera/abilities/phase3_blue_team_validation.yml`.
3. Scope operation to approved endpoint hosts only.
4. Execute operation with deterministic ordering: Step 1 -> Step 2 -> Step 3.
5. Export operation report artifact for detection validation evidence.

## 5. Safety and Boundary Controls
1. No lateral movement modules outside declared endpoints.
2. No persistence or destructive payload modules.
3. No Core Services disruption actions permitted.
4. All operations must remain within allow-listed host inventory groups.

## 6. Success Criteria
Scenario `PH3-ATK-001` is successful only when:
1. Caldera operation completes without manual host-side intervention.
2. Endpoint logs contain the expected execution/authentication artifacts.
3. Wazuh generates corresponding alerts for each attack stage.
4. Re-running the same scenario produces equivalent detections.
