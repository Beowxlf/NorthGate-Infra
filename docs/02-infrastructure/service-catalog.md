# Service Catalog (Target-State)

## Catalog Purpose
This catalog defines the intended end-state service architecture for a segmented Blue Team lab. It is the baseline for future Infrastructure as Code implementation and deliberately replaces flat-network assumptions with explicit trust zones and service boundaries.

## Target Logical Zones and Trust Boundaries

| Zone | Trust Level | Primary Function | Inbound/Outbound Expectations |
|---|---|---|---|
| Management Zone | Highest (admin-only) | Administrative control plane and privileged operations | Inbound only from admin jump paths; outbound to all managed zones on tightly scoped management ports |
| Core Services Zone | High | Identity, name services, time, shared core infrastructure | Limited inbound from internal zones; outbound for replication/updates/telemetry only |
| Monitoring / Security Zone | High | Central logging, metrics, SIEM, and detection tooling | Receives telemetry from all zones; limited outbound for agent management and alerting |
| Workbench / Adversary Simulation Zone | Medium-Low (controlled offensive tooling) | Detection engineering, malware detonation, adversary simulation orchestration | Strictly egress-controlled; isolated from direct user production-like access |
| Application Hosting Zone | Medium | ScrambleIQ application and supporting data services | Receives traffic only via approved ingress path; restricted east-west access |
| User / Endpoint Zone | Medium-Low | User workstations, test endpoints, admin practice systems | Outbound to core and monitoring services; no unrestricted lateral access |

## Environment Definitions
- `test-core`: foundational infrastructure and shared enterprise-style services.
- `workbench`: security engineering, malware analysis, and adversary simulation systems.
- `app-hosting`: ScrambleIQ runtime and supporting application services.

---

## 1) Core Infrastructure

### Service: Active Directory Domain Services (AD DS)
- **Purpose:** Centralized identity, authentication, authorization, and policy anchor for domain-joined systems.
- **Layer:** Core Infrastructure
- **Target zone:** Core Services Zone
- **Target environment:** `test-core`
- **Dependencies:** DNS, NTP/Time service, backup service, virtualization/compute base, firewall policy.
- **Failure impact:** Domain logons and GPO application degrade/fail; service-to-service auth disruptions across lab.
- **Implementation notes:** Deploy at least two domain controllers in `test-core`; restrict administrative access to Management Zone jump hosts; enforce secure LDAP and audited privileged groups.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Internal DNS (AD-integrated)
- **Purpose:** Authoritative internal name resolution for all zones and service discovery.
- **Layer:** Core Infrastructure
- **Target zone:** Core Services Zone
- **Target environment:** `test-core`
- **Dependencies:** AD DS (for integrated zones), network segmentation controls, time synchronization.
- **Failure impact:** Cross-zone service resolution breaks; authentication and telemetry routing instability.
- **Implementation notes:** Split-horizon where required; no recursive open resolver behavior; zone transfer restricted by ACLs.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Network Time Service (NTP/Chrony hierarchy)
- **Purpose:** Consistent time source for authentication, correlation, and forensic timelines.
- **Layer:** Core Infrastructure
- **Target zone:** Core Services Zone
- **Target environment:** `test-core`
- **Dependencies:** Upstream authoritative time source, firewall policy, DNS.
- **Failure impact:** Kerberos/auth issues, broken event correlation, reduced detection confidence.
- **Implementation notes:** Establish internal stratum hierarchy; force all zones to use approved internal time sources.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: File Services (SMB/NFS share platform)
- **Purpose:** Central file share for lab artifacts, controlled data exchange, and admin practice workflows.
- **Layer:** Core Infrastructure
- **Target zone:** Core Services Zone
- **Target environment:** `test-core`
- **Dependencies:** AD DS, DNS, storage backend, backup/restore service, anti-malware scanning pipeline.
- **Failure impact:** Collaboration and artifact transfer interruptions; admin training workflows degraded.
- **Implementation notes:** Enforce least-privilege ACLs by role; separate operational shares from malware-analysis transfer shares.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Backup and Recovery Service
- **Purpose:** Scheduled backup, retention, and restore workflows for infrastructure and application data.
- **Layer:** Core Infrastructure
- **Target zone:** Core Services Zone
- **Target environment:** `test-core`
- **Dependencies:** Storage repository, network reachability to protected workloads, service accounts from AD DS.
- **Failure impact:** Extended outage recovery times and potential permanent data loss after incidents or exercises.
- **Implementation notes:** Define zone-aware backup windows; test restores quarterly; protect backup credentials in privileged vault.
- **Phase:** Phase 2
- **Disposition:** rebuild

---

## 2) Observability

### Service: Central Metrics Platform (Prometheus-compatible)
- **Purpose:** Collects infrastructure and service metrics for health and capacity visibility.
- **Layer:** Observability
- **Target zone:** Monitoring / Security Zone
- **Target environment:** `test-core`
- **Dependencies:** Service exporters/agents in all zones, DNS, time service, storage.
- **Failure impact:** Reduced situational awareness; delayed fault detection and triage.
- **Implementation notes:** Use pull model with firewall exceptions per zone; retain short/mid-term metrics locally.
- **Phase:** Phase 2
- **Disposition:** rebuild

### Service: Visualization and Dashboards (Grafana-compatible)
- **Purpose:** Shared dashboards for operations, security, and exercise observability.
- **Layer:** Observability
- **Target zone:** Monitoring / Security Zone
- **Target environment:** `test-core`
- **Dependencies:** Metrics platform, log/SIEM data sources, SSO/AD integration.
- **Failure impact:** Stakeholders lose consolidated visibility but core workloads continue running.
- **Implementation notes:** RBAC by team role; immutable dashboard baselines via configuration as code.
- **Phase:** Phase 2
- **Disposition:** rebuild

### Service: Central Log Pipeline (collector + parsing + retention)
- **Purpose:** Normalizes and routes logs from all zones into security and operations analytics.
- **Layer:** Observability
- **Target zone:** Monitoring / Security Zone
- **Target environment:** `test-core`
- **Dependencies:** Endpoint/service log shippers, storage tier, DNS, certificates/PKI.
- **Failure impact:** Loss of audit trail continuity and reduced incident response capability.
- **Implementation notes:** Enforce TLS for ingestion; isolate raw and parsed retention tiers; define schema/version governance.
- **Phase:** Phase 1
- **Disposition:** rebuild

---

## 3) Security / Detection

### Service: Wazuh Manager / SIEM Stack
- **Purpose:** Security event aggregation, rule-based detection, alert generation, and compliance visibility.
- **Layer:** Security / Detection
- **Target zone:** Monitoring / Security Zone
- **Target environment:** `test-core`
- **Dependencies:** Central log pipeline, agent deployment framework, DNS, storage, time service.
- **Failure impact:** Security monitoring blind spots and missed detections across lab zones.
- **Implementation notes:** Preserve as strategic security platform; deploy HA-ready architecture; tune detection content per zone profile.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Endpoint Telemetry Agents (Wazuh + Sysmon/OSQuery profile)
- **Purpose:** Host-level telemetry and policy enforcement hooks for detection engineering.
- **Layer:** Security / Detection
- **Target zone:** User / Endpoint Zone (primary), plus all managed zones where applicable
- **Target environment:** `test-core`, `workbench`, `app-hosting`
- **Dependencies:** Wazuh Manager, central log pipeline, host baseline configuration, DNS.
- **Failure impact:** Per-endpoint visibility loss; weakened detection development and validation.
- **Implementation notes:** Maintain separate policy profiles by zone (e.g., stricter in workbench detonation network).
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Detection Content Repository and CI Pipeline
- **Purpose:** Versioned rules, decoders, correlation logic, and automated validation for detection engineering.
- **Layer:** Security / Detection
- **Target zone:** Management Zone
- **Target environment:** `workbench`
- **Dependencies:** Source control service, test replay datasets, Wazuh staging interface, CI runner.
- **Failure impact:** Detection changes become ad hoc; slower and riskier security content iteration.
- **Implementation notes:** Treat detections as code; enforce promotion gates (dev → staging → production).
- **Phase:** Phase 2
- **Disposition:** rebuild

### Service: Tactical RMM
- **Purpose:** Legacy remote management platform currently present in temporary state.
- **Layer:** Security / Detection
- **Target zone:** Management Zone (temporary)
- **Target environment:** `test-core`
- **Dependencies:** Agent footprint on endpoints, management access paths.
- **Failure impact:** Minimal in target state (superseded by hardened admin workflows and configuration management).
- **Implementation notes:** Keep only long enough to support migration; prohibit new dependencies.
- **Phase:** Phase 1
- **Disposition:** remove

---

## 4) Adversary Simulation

### Service: MITRE Caldera Server
- **Purpose:** Coordinated adversary emulation for purple-team and detection validation exercises.
- **Layer:** Adversary Simulation
- **Target zone:** Workbench / Adversary Simulation Zone
- **Target environment:** `workbench`
- **Dependencies:** DNS, isolated operator access path, approved target allowlists, telemetry collection in monitored zones.
- **Failure impact:** Reduced ability to validate detections and response playbooks against realistic techniques.
- **Implementation notes:** No direct placement in core or app zones; brokered access only through policy-controlled paths.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Adversary Emulation Agents / Redirector Hosts
- **Purpose:** Controlled execution points for scripted attack chains and payload delivery simulation.
- **Layer:** Adversary Simulation
- **Target zone:** Workbench / Adversary Simulation Zone
- **Target environment:** `workbench`
- **Dependencies:** Caldera server, network ACL policy, snapshot-capable compute templates.
- **Failure impact:** Partial/failed emulation scenarios; reduced exercise realism.
- **Implementation notes:** Rotate images frequently; maintain strict egress controls and deny-by-default inter-zone rules.
- **Phase:** Phase 2
- **Disposition:** rebuild

### Service: Malware Detonation Sandbox
- **Purpose:** Isolated analysis and controlled detonation environment for malware behavior observation.
- **Layer:** Adversary Simulation
- **Target zone:** Workbench / Adversary Simulation Zone (isolated detonation enclave)
- **Target environment:** `workbench`
- **Dependencies:** Snapshot/rollback virtualization, sinkhole DNS option, telemetry forwarding, quarantine storage.
- **Failure impact:** Malware analysis capability unavailable; increased risk if analysts bypass controlled process.
- **Implementation notes:** Physically/logically isolate from production-like traffic; one-way telemetry export to monitoring zone.
- **Phase:** Phase 2
- **Disposition:** rebuild

---

## 5) Application Hosting

### Service: Reverse Proxy / Ingress Gateway
- **Purpose:** Controlled ingress, TLS termination, and request routing for ScrambleIQ services.
- **Layer:** Application Hosting
- **Target zone:** Application Hosting Zone
- **Target environment:** `app-hosting`
- **Dependencies:** Internal PKI/cert lifecycle, DNS, ScrambleIQ app services, firewall policy.
- **Failure impact:** Application becomes unreachable or degraded for intended users.
- **Implementation notes:** Single entry pattern; no direct client access to backend application or data tiers.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: ScrambleIQ Application Runtime
- **Purpose:** Hosts core ScrambleIQ application services and APIs.
- **Layer:** Application Hosting
- **Target zone:** Application Hosting Zone
- **Target environment:** `app-hosting`
- **Dependencies:** Ingress gateway, application database, identity integration (AD/IdP bridge as needed), centralized logging.
- **Failure impact:** Primary lab application unavailable; user workflows interrupted.
- **Implementation notes:** Keep app runtime concerns separate from infra control plane; support blue/green or canary-ready deployment pattern.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: ScrambleIQ Data Store
- **Purpose:** Persistent storage for ScrambleIQ transactional and configuration data.
- **Layer:** Application Hosting
- **Target zone:** Application Hosting Zone
- **Target environment:** `app-hosting`
- **Dependencies:** Storage subsystem, backup/recovery service, runtime service accounts/secrets.
- **Failure impact:** Data loss risk and total/partial app outage.
- **Implementation notes:** No direct user-zone connectivity; only app runtime and approved admin paths may connect.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Background Worker / Job Runner (ScrambleIQ)
- **Purpose:** Asynchronous task execution for reporting, enrichment, and maintenance jobs.
- **Layer:** Application Hosting
- **Target zone:** Application Hosting Zone
- **Target environment:** `app-hosting`
- **Dependencies:** Application runtime, message queue (if adopted), data store, logging pipeline.
- **Failure impact:** Deferred features degrade; core UI/API may remain partially functional.
- **Implementation notes:** Scale independently from web/API tier; implement idempotent job semantics.
- **Phase:** future-state
- **Disposition:** rebuild

---

## 6) Control Plane

### Service: Infrastructure Provisioning Controller (Terraform/OpenTofu runner)
- **Purpose:** Declarative provisioning pipeline for compute, network, and baseline infrastructure constructs.
- **Layer:** Control Plane
- **Target zone:** Management Zone
- **Target environment:** `test-core`
- **Dependencies:** Source control, state backend, secrets management, administrative network paths.
- **Failure impact:** No controlled infrastructure changes; emergency modifications become manual/high risk.
- **Implementation notes:** Isolate runner credentials; enforce plan/apply approvals and state locking.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Configuration Management Controller (Ansible automation node)
- **Purpose:** Baseline configuration, hardening, and day-2 operations across all zones.
- **Layer:** Control Plane
- **Target zone:** Management Zone
- **Target environment:** `test-core`
- **Dependencies:** Inventory source, privileged vault, SSH/WinRM access controls, DNS.
- **Failure impact:** Configuration drift increases; patch and hardening workflows stall.
- **Implementation notes:** Separate inventories per zone; enforce just-in-time privileged execution.
- **Phase:** Phase 1
- **Disposition:** rebuild

### Service: Secrets and PKI Service
- **Purpose:** Central secrets issuance/rotation and internal certificate authority functions.
- **Layer:** Control Plane
- **Target zone:** Management Zone
- **Target environment:** `test-core`
- **Dependencies:** AD integration (optional), secure storage, backup policy, administrative MFA controls.
- **Failure impact:** Certificate/credential rotation halts; service trust relationships degrade over time.
- **Implementation notes:** Required for TLS between zones and machine identity hardening.
- **Phase:** Phase 2
- **Disposition:** rebuild

### Service: Bastion / Privileged Access Workstation (PAW) Gateway
- **Purpose:** Controlled administrative entry point for all privileged operations.
- **Layer:** Control Plane
- **Target zone:** Management Zone
- **Target environment:** `test-core`
- **Dependencies:** Identity service, MFA controls, session auditing, firewall policy.
- **Failure impact:** Administrative workflows blocked unless break-glass process exists.
- **Implementation notes:** Mandatory jump-path into other zones; disallow direct admin from user endpoints.
- **Phase:** Phase 1
- **Disposition:** rebuild

---

## Segmentation Alignment Summary
This target-state catalog enforces non-flat architecture by assigning every service to a zone with explicit trust posture, constrained dependencies, and phased migration disposition. Core identity and foundational services reside in the Core Services Zone, centralized monitoring/detection in Monitoring/Security, offensive and malware workflows in the isolated Workbench zone, ScrambleIQ in Application Hosting, and all privileged automation in Management. This provides a practical baseline for detection engineering, safe adversary emulation, operational administration practice, and resilient application hosting without collapsing trust boundaries.
