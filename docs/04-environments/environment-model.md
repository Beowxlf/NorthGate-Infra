# Environment and Security Zone Model

## Purpose
This document defines the target environment and zone model for a segmented Blue Team lab so that:
- environment purpose is distinct from network/security-zone purpose,
- service placement is explicit and repeatable,
- communication policy can be enforced with routed controls,
- the design can be implemented progressively with Infrastructure as Code (IaC).

## 1) Environment Definitions

### `test-core`
**Purpose**
- Host foundational shared services required by all other environments.
- Serve as the first validation point for core IaC modules and baseline hardening.

**Included service types**
- Identity and directory services.
- Naming and time services.
- Central monitoring/security management services.
- Shared backup/control-plane support services (if required by core operations).

**Operational role**
- Platform anchor for trust, telemetry, and shared service discovery.
- Upstream dependency provider to `workbench` and `app-hosting`.

---

### `workbench`
**Purpose**
- Provide operator administration, automation control, and adversary simulation capabilities in a controlled environment.

**Included service types**
- Bastion/jump administration systems.
- IaC and configuration management control nodes.
- Security validation and adversary emulation tooling.
- Malware analysis/detonation systems (isolated from core services).

**Operational role**
- Execution plane for change operations and controlled security testing.
- Staging area for runbooks, playbooks, and security exercises before production-like use.

---

### `app-hosting`
**Purpose**
- Run application workloads and associated data services separate from security testing infrastructure.

**Included service types**
- Ingress/reverse proxy services.
- Application runtime hosts.
- Application databases and optional workers/queues.
- Application-adjacent observability agents/collectors.

**Operational role**
- Runtime delivery environment for business-facing services.
- Consumer of shared identity, DNS, and monitoring capabilities from `test-core`.

## 2) Zone Definitions

### Management Zone
**Purpose**
- Constrain administrative access paths and privileged orchestration traffic.

**Typical systems**
- Jump host/bastion.
- Automation control node (Terraform/OpenTofu, Ansible, CI runners for infra).
- Privileged access workflow services (if introduced).

**Sensitivity level**
- **Critical / Tier 0-1 administrative plane** (highest control requirements).

---

### Core Services Zone
**Purpose**
- Provide foundational enterprise/lab shared services that other zones depend on.

**Typical systems**
- Domain Controller / directory services.
- DNS/NTP and related core infrastructure services.
- Shared PKI or secrets backends (future-state as needed).

**Sensitivity level**
- **High / foundational trust services**.

---

### Monitoring / Security Zone
**Purpose**
- Centralize security visibility, telemetry ingestion, and detection content.

**Typical systems**
- Wazuh manager/indexer/dashboard.
- Prometheus/Grafana and security metrics stores.
- Log aggregation and SIEM-adjacent tooling.

**Sensitivity level**
- **High / sensitive telemetry and detection content**.

---

### Workbench / Adversary Simulation Zone
**Purpose**
- Host controlled attack simulation and research tooling without contaminating core trust zones.

**Typical systems**
- Caldera/C2 simulation control components.
- Attack simulation hosts.
- Malware detonation/sandbox analysis systems.

**Sensitivity level**
- **High risk / controlled-containment zone** (hostile tooling allowed, strict egress controls).

---

### Application Hosting Zone
**Purpose**
- Isolate application runtime and data paths from administrative and adversary simulation infrastructure.

**Typical systems**
- Reverse proxies/load balancers.
- Application services/API hosts.
- Application database and worker nodes.

**Sensitivity level**
- **Medium-to-high / production-like service data**.

---

### User / Endpoint Zone
**Purpose**
- Represent analyst/user workstations and test endpoints that generate realistic activity.

**Typical systems**
- Blue Team analyst workstations.
- Test clients and endpoint workloads.
- Simulated user devices.

**Sensitivity level**
- **Medium / untrusted-to-semi-trusted endpoint plane**.

## 3) Service Placement (Environment + Zone)

| Service / Capability | Environment | Security Zone | Placement Rationale |
|---|---|---|---|
| Domain Controller / Directory | `test-core` | Core Services Zone | Keeps trust anchors centralized and isolated from user/app/attack workloads. |
| DNS / NTP | `test-core` | Core Services Zone | Core dependencies for all environments with controlled inbound rules. |
| Wazuh Manager Stack | `test-core` | Monitoring / Security Zone | Central detection/response platform separated from directory services. |
| Prometheus / Grafana | `test-core` | Monitoring / Security Zone | Shared observability control plane, not co-located with app runtime. |
| Bastion / Jump Host | `workbench` | Management Zone | Single managed admin ingress point. |
| IaC / Ansible Control Node | `workbench` | Management Zone | Constrained privileged automation source. |
| Caldera / Adversary Emulation | `workbench` | Workbench / Adversary Simulation Zone | Deliberately separated from app-hosting and core trust zones. |
| Malware Detonation / Sandbox | `workbench` | Workbench / Adversary Simulation Zone | High-risk tooling is contained away from Core Services Zone. |
| Reverse Proxy / Ingress | `app-hosting` | Application Hosting Zone | Front-door for application traffic with restricted upstream paths. |
| Application Runtime (ScrambleIQ) | `app-hosting` | Application Hosting Zone | Business workload isolation from admin/security testing planes. |
| Database / Worker Services | `app-hosting` | Application Hosting Zone | Data plane remains inside app zone with least-privilege access. |
| Analyst Workstations / Test Endpoints | `workbench` (or dedicated endpoint env later) | User / Endpoint Zone | User activity generation and SOC workflows segregated from control planes. |

## 4) Allowed Communication Model

## Guiding policy
- Default deny between zones/environments.
- Explicitly allow only required flows (protocol, port, source, destination).
- No direct lateral trust between Workbench/Adversary systems and Core Services except tightly scoped management flows.

### Allowed high-level paths (target state)
1. **User / Endpoint Zone → Application Hosting Zone**
   - Allow user/application protocols to published ingress only.
   - Deny direct endpoint access to databases and management interfaces.

2. **Application Hosting Zone → Core Services Zone**
   - Allow required service dependencies (e.g., DNS, directory auth if needed, time sync).
   - Deny broad east-west administrative access.

3. **All workload zones → Monitoring / Security Zone**
   - Allow telemetry/log/metrics forwarding to approved collectors/managers.
   - Deny reverse interactive sessions from monitoring tools unless explicitly authorized for response workflows.

4. **Management Zone → all managed zones**
   - Allow tightly controlled administrative protocols from bastion/control node to managed hosts.
   - Require identity-based admin controls and auditable sessions.

5. **Workbench / Adversary Simulation Zone → target zones (exercise windows only)**
   - Allow time-bound, scenario-bound traffic used for validation exercises.
   - Enforce explicit approval and logging; default deny outside exercises.

### Restricted / denied paths (future enforced baseline)
- Deny **Application Hosting Zone ↔ Workbench / Adversary Simulation Zone** direct free-form connectivity.
- Deny **Workbench / Adversary Simulation Zone → Core Services Zone** except narrowly approved management prerequisites.
- Deny **User / Endpoint Zone → Core Services Zone** administrative protocols.
- Deny **Internet/External → Core Services Zone** direct access.
- Deny **malware detonation systems → unrestricted egress**; allow only curated update/intel channels as required.

## 5) Evolution Path (Current Infrastructure → Segmented Target)

### Phase A: Structured logical segmentation on current network
- Keep existing infrastructure operational but define zones/environments in IaC inventory and tagging.
- Apply host firewalls and ACL-style rules to emulate inter-zone policy.
- Move services to correct logical placements (especially isolating adversary tooling and app hosting).

### Phase B: Routed segmentation introduction
- Create dedicated VLANs/subnets per zone.
- Introduce L3 gateways/firewall policy between zones with default-deny rule sets.
- Route all inter-zone traffic through policy enforcement points with logging.

### Phase C: Strong enforcement and identity-centric control
- Replace broad network allows with least-privilege rule objects tied to service identities.
- Add privileged access workflow controls for Management Zone operations.
- Implement stronger egress controls, especially for Workbench/Adversary and malware analysis systems.

### Phase D: Continuous verification in IaC
- Encode zone boundaries, routes, and firewall policy in Terraform/OpenTofu modules.
- Add policy-as-code checks in CI to prevent flat-network regressions.
- Validate communication intent with automated reachability tests per release.

## Design Guardrails (Non-Negotiable)
- The target architecture is **not** a flat network.
- `app-hosting` services are separated from `workbench` attack/adversary services.
- Malware detonation/sandbox systems are never placed in Core Services Zone.
- All segmentation intent is represented in IaC artifacts so enforcement is repeatable and auditable.
