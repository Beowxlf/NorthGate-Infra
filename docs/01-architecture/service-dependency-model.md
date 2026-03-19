# Service Dependency and Trust-Boundary Model (Target State)

## Purpose
This document defines the **target-state** service interaction model for NorthGate-Infra so the architecture can be translated into VLANs, firewall policy, routing controls, and infrastructure-as-code guardrails.

The model is intentionally textual (no diagrams) and assumes phased implementation: some controls may be partial in the current state, but all flows and boundaries below represent the desired end state.

---

## 1) Logical Zones

### Zone A — Management Zone
**Intent:** administrative control plane and privileged operator ingress.

**Typical services/components:**
- Jump host / bastion
- Control node (Ansible, Terraform/OpenTofu orchestration)
- Administrative package/cache mirrors (optional)
- Privileged secrets/bootstrap tooling (if used)

**Trust level:** very high (privileged).

**Allowed communications (high level):**
- To Core Services Zone for identity, DNS, time, and platform telemetry.
- To all managed zones for automation/administration on explicitly allow-listed management ports.
- No direct inbound access from User/Endpoint Zone.

---

### Zone B — Core Services Zone
**Intent:** shared foundational services required by nearly all systems.

**Typical services/components:**
- Domain Controller (AD DS / identity)
- DNS service
- Time source (NTP/chrony role; may be co-hosted)
- PKI/CA components (if implemented)

**Trust level:** very high (enterprise control dependencies).

**Allowed communications (high level):**
- Receives identity and naming requests from all other zones.
- Limited administrative access from Management Zone only.
- No lateral administrative trust from Workbench directly to core services except approved workflows.

---

### Zone C — Monitoring / Security Zone
**Intent:** detection, telemetry aggregation, and defensive visibility.

**Typical services/components:**
- Wazuh manager/indexer/dashboard components
- Prometheus
- Grafana
- Alert routing/integrations (optional)

**Trust level:** high (security-sensitive data).

**Allowed communications (high level):**
- Receives logs/metrics/security telemetry from endpoints and servers in other zones.
- Exposes read-only dashboards to approved analyst/admin roles.
- Management access restricted to Management Zone.

---

### Zone D — Workbench / Adversary Simulation Zone
**Intent:** controlled attack emulation and validation of detections.

**Typical services/components:**
- Caldera server
- Adversary simulation operators/agents
- Attack tooling workstation(s)
- Malware analysis utilities (non-production)

**Trust level:** constrained high-risk zone (intentionally hostile tooling).

**Allowed communications (high level):**
- Can initiate approved simulation traffic toward target systems in User/Endpoint and Application Hosting zones.
- Must not have unrestricted access to Core Services Zone.
- Full logging of commands/operations sent to Monitoring/Security Zone where feasible.

---

### Zone E — Application Hosting Zone
**Intent:** host application services and data plane for lab workloads.

**Typical services/components:**
- Reverse proxy / ingress
- Application service(s)
- Application database
- Optional background worker(s)

**Trust level:** medium-high (business/data risk).

**Allowed communications (high level):**
- Receives user/application traffic from User/Endpoint Zone through controlled ingress paths.
- Depends on Core Services (identity/DNS/time) and Monitoring/Security services.
- Does not initiate privileged control-plane actions into Management Zone.

---

### Zone F — User / Endpoint Zone
**Intent:** user workstations and managed endpoints that represent enterprise clients.

**Typical services/components:**
- Windows/Linux client endpoints
- Test user systems
- Endpoint agents (Wazuh/logging/metrics)

**Trust level:** medium/variable (primary attack surface).

**Allowed communications (high level):**
- Uses Core Services for DNS/identity/time.
- Sends telemetry to Monitoring/Security Zone.
- Accesses Application Hosting Zone via approved user/application ports.
- Receives controlled simulation traffic from Workbench Zone during exercises.

---

## 2) Service Dependency Model

Below, “upstream” means required providers a service consumes; “downstream” means services/workflows that rely on it.

### Domain Controller (DC)
- **Upstream dependencies:**
  - Network reachability to its own storage/OS platform
  - Accurate time source (authoritative or synchronized hierarchy)
  - DNS role availability (if split role)
- **Downstream dependencies:**
  - Authentication/authorization for Management, Application, and Endpoint systems
  - Group policy/domain policy distribution for endpoints
  - Service account authentication used by automation and services
- **Operational notes:**
  - DC and DNS should be treated as tier-0 services with prioritized startup and backup.
  - If multiple DCs exist later, clients must have ordered failover.

### DNS
- **Upstream dependencies:**
  - Network and service process availability
  - Directory integration (if AD-integrated DNS)
- **Downstream dependencies:**
  - Nearly all services (Wazuh agents, Prometheus targets, Caldera, app tiers)
  - Automation workflows resolving inventory hostnames
- **Operational notes:**
  - DNS must be reachable before most configuration orchestration can complete reliably.
  - Split-horizon/internal zones should align with trust-boundary policy.

### Wazuh (Manager/Indexer/Dashboard)
- **Upstream dependencies:**
  - DNS and time synchronization
  - Underlying storage/index capacity
  - Network access from agents/endpoints and servers
- **Downstream dependencies:**
  - SOC/Blue Team detection workflows
  - Compliance/event triage dashboards
  - Alert-driven incident response playbooks
- **Operational notes:**
  - Agent enrollment and key distribution should be automated via management tooling.
  - Ingestion throughput and index retention need explicit capacity policy.

### Prometheus
- **Upstream dependencies:**
  - DNS/time
  - Scrape target endpoint/exporter reachability
- **Downstream dependencies:**
  - Grafana dashboards
  - Availability/performance alerting
- **Operational notes:**
  - Scrape ACLs must follow zone policy (pull model should not bypass segmentation intent).

### Grafana
- **Upstream dependencies:**
  - Prometheus and optional security data sources
  - Identity provider integration (local or domain-backed)
- **Downstream dependencies:**
  - Operator and analyst observability interface
- **Operational notes:**
  - Role-based access should separate admin, analyst, and read-only personas.

### Caldera
- **Upstream dependencies:**
  - DNS/time
  - Operator access from Management/Workbench
  - Network path to designated targets
- **Downstream dependencies:**
  - Attack simulation campaigns against endpoints/application targets
  - Validation signals consumed by Wazuh/monitoring systems
- **Operational notes:**
  - Campaign profiles should be bounded by allow-listed target scope.
  - Caldera failure must not impact production-like app availability.

### Jump Host / Bastion
- **Upstream dependencies:**
  - Identity (domain/local auth), DNS, and network perimeter controls
- **Downstream dependencies:**
  - Human administrative access to management interfaces
- **Operational notes:**
  - Should enforce MFA/session logging where feasible.

### Control Node (IaC/Config Management)
- **Upstream dependencies:**
  - DNS, identity, SCM/artifact access, secrets access
- **Downstream dependencies:**
  - Provisioning and configuration of all managed zones
  - Agent rollout (Wazuh/exporters) and policy convergence
- **Operational notes:**
  - Control node unavailability affects change velocity, not necessarily running workload continuity.

### Reverse Proxy / Application Gateway
- **Upstream dependencies:**
  - DNS certificates/secrets, app backend reachability
- **Downstream dependencies:**
  - User-facing access path to application services
- **Operational notes:**
  - Serves as choke point for access control, request logging, and TLS termination.

### Application Service
- **Upstream dependencies:**
  - Reverse proxy routing
  - Database connectivity
  - DNS/time/identity as required by app auth model
- **Downstream dependencies:**
  - End-user business workflows
  - Optional worker job production/consumption
- **Operational notes:**
  - App health should fail fast when DB is unavailable to avoid silent corruption.

### Application Database
- **Upstream dependencies:**
  - Persistent storage integrity
  - DNS/time and secret-managed credentials
- **Downstream dependencies:**
  - Application service and workers
  - Reporting/analytics jobs (if present)
- **Operational notes:**
  - Consider this critical stateful dependency with strict backup/restore objectives.

### Endpoint Agents (Wazuh/logging/metrics)
- **Upstream dependencies:**
  - Endpoint OS health
  - DNS resolution and egress to Monitoring/Security zone collectors
- **Downstream dependencies:**
  - Detection pipelines and endpoint posture visibility
- **Operational notes:**
  - Agent deployment should be policy-driven and continuously reconciled.

---

## 3) Security Flow Model

### Endpoint telemetry flow
1. Endpoint in User/Endpoint or Application Hosting Zone generates host events (process, auth, file, network, security).
2. Endpoint security/monitoring agents normalize and forward telemetry over allow-listed channels.
3. Telemetry is received in Monitoring/Security Zone (Wazuh and/or metrics collectors).
4. Parsed events are indexed/stored for alerting, hunting, and historical analysis.

### Logging flow
1. Infrastructure and service logs are produced in each zone (management, core, app, workbench, endpoints).
2. Logs are forwarded via defined collectors/agents, not by ad hoc direct database writes across zones.
3. Centralized log/security stores in Monitoring/Security Zone apply parsing, enrichment, and retention policy.
4. Dashboards and alerts consume normalized data through controlled read interfaces.

### Wazuh ingestion flow
1. Wazuh agents on endpoints/servers establish trusted enrollment with Wazuh manager.
2. Agents send security events to manager.
3. Manager applies decoding/rules and writes to indexer storage.
4. Detection outputs are available via Wazuh dashboard and downstream alert channels.

### Dashboard and monitoring access flow
1. User/admin authenticates through approved identity path (domain/local RBAC policy).
2. Access to Grafana/Wazuh dashboards is role-constrained and audited.
3. Dashboards read from telemetry stores; they do not require direct cross-zone host access.
4. Privileged dashboard administration is allowed only from Management Zone pathways.

---

## 4) Attack Simulation Flow

1. **Campaign initiation:** Caldera operators in Workbench Zone launch a bounded adversary profile against pre-approved targets.
2. **Execution on targets:** Target endpoints (typically User/Endpoint Zone, optionally Application Hosting Zone test nodes) execute simulated TTP activity.
3. **Target-side telemetry:** Endpoint logs, process events, and security signals are generated immediately on target hosts.
4. **Collection and detection:** Agents forward events to Wazuh/monitoring stack in Monitoring/Security Zone.
5. **Analyst validation:** Blue Team validates detections in Wazuh/Grafana dashboards and confirms alert quality, timing, and coverage.
6. **Containment of exercise blast radius:** Firewall/ACL policy ensures simulation traffic is restricted to approved target lists and ports.

---

## 5) Malware Detonation Flow (Isolated Path)

### Intended isolated execution path
1. Suspicious sample is transferred to a **dedicated detonation host/sandbox** in Workbench/isolated analysis segment.
2. Detonation host executes sample with egress policy set to default-deny except explicitly approved sinkhole/simulation endpoints.
3. Detonation host sends telemetry/artifacts (behavioral logs, hashes, pcap metadata) to Monitoring/Security Zone.
4. Findings are reviewed from Management Zone via approved administrative access.

### Systems that **should be reachable** from detonation environment
- Monitoring/Security collectors required for observation.
- Controlled update/signature repositories only if explicitly allow-listed.
- Optional sinkhole infrastructure used for safe C2 emulation.

### Systems that **should NOT be reachable** from detonation environment
- Domain Controller and broader Core Services administrative interfaces.
- Production-like application databases and sensitive app backends.
- Management Zone control interfaces (except tightly controlled one-way collection/log export patterns).
- General outbound internet (unless routed through explicit inspection/sinkhole policy for specific tests).

### Isolation requirements
- Separate subnet/VLAN and strict firewall deny-by-default policy.
- No trust relationship from detonation host into domain tier-0 assets.
- Rapid revert/rebuild workflow (snapshot/immutable image approach) after each run.

---

## 6) Failure Impact Model

### If Domain Controller (DC) fails
- Domain logon/auth and group policy workflows degrade or stop.
- Service accounts relying on domain auth fail, impacting automation and service-to-service auth.
- Existing active sessions may continue temporarily, but new privileged workflows are disrupted.

### If DNS fails
- Hostname resolution breaks across zones; many services appear “down” despite process health.
- Agent-to-manager connectivity, scrape targets, and app service discovery fail.
- Automation pipelines that rely on inventory FQDNs stall or fail.

### If Wazuh fails
- Security event ingestion and correlation are interrupted.
- Detection blind spots emerge; incident triage quality drops.
- Core business/app traffic may continue, but defensive assurance is significantly reduced.

### If Caldera fails
- Adversary simulation campaigns cannot be initiated/managed.
- Blue Team validation cadence is reduced, but core identity/app services remain operational.
- This is a testing-capability loss, not typically a production service outage.

### If application database fails
- Application read/write paths fail or enter degraded mode depending on app design.
- User-facing functionality requiring persistent state becomes unavailable.
- Downstream jobs/analytics dependent on app data stop or produce stale results.

---

## 7) Mapping Readiness for VLANs, Firewall Rules, and IaC

To make this model directly translatable into implementation artifacts:
- Express each zone as a network/security object (future VLAN/subnet/security-group unit).
- Express each allowed flow as explicit source zone → destination zone → protocol/port rule.
- Encode dependencies as IaC module inputs and configuration-management prechecks.
- Gate service rollout on dependency health checks (DNS, time, identity, telemetry).
- Keep detonation and adversary-simulation policies separate from standard user/application paths.
