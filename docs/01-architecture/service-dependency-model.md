# Service Dependency Model

## Purpose
Define deterministic service dependencies, communication paths, trust boundaries, failure effects, and architectural layering for the NorthGate lab.

---

## 1) Layering Model

### Architecture Layer
- Defines environment roles (`test-core`, `workbench`, `app-hosting`), trust zones, and service contracts.
- Defines which services are mandatory vs optional by phase.

### Infrastructure Layer (Terraform/OpenTofu)
- Provisions VM/node resources, network segments, firewall objects, storage allocations, and base topology.
- Does **not** perform deep service-specific runtime configuration.

### Configuration Layer (Ansible)
- Installs/configures services, users, policies, monitoring agents, backup jobs, and hardening baselines.
- Enforces idempotent desired state on provisioned infrastructure.

### Application Layer
- Deploys and configures ScrambleIQ runtime, reverse proxy routing, app dependencies, and optional worker behavior.

### Image Layer (Packer, cross-cutting)
- Produces reusable hardened base images consumed by infrastructure provisioning.
- Reduces bootstrap variance for high-trust hosts (jump host, control node, attack box, app host).

---

## 2) High-Level Dependency Graph

1. **Firewall + Network Topology** provide segmentation and allowed communication paths.
2. **Time Synchronization** must be stable before identity, monitoring, and TLS-dependent services are trusted.
3. **DNS** must resolve all managed service names before automation and inter-service communication.
4. **Domain Controller** depends on DNS/time and enables centralized identity.
5. **Management Plane (Jump Host + Control Node)** depends on identity, DNS, firewall, and secrets.
6. **Observability/Security Plane (Prometheus, Grafana, Wazuh)** depends on network, DNS, time, and agent deployment.
7. **Adversary Simulation Plane (Caldera + Attack Box)** depends on management plane and controlled network paths.
8. **Application Plane (Reverse Proxy, App Host, DB, optional Worker)** depends on core network/identity/time plus secrets, backup, and observability hooks.

---

## 3) Communication Paths

### Core Paths
- Control Node → all managed nodes (provision/config channels).
- Jump Host → administrative endpoints only.
- All nodes → DNS resolver.
- All nodes → time source.

### Observability/Security Paths
- Wazuh Agents → Wazuh Manager.
- Prometheus → exporters/services.
- Grafana → Prometheus (and optional security data sources where integrated).

### Adversary Simulation Paths
- Caldera/Attack Box → approved target nodes over explicit firewall-allowed test channels.
- Target nodes → Wazuh Manager and monitoring stack for detection confirmation.

### Application Paths
- Client/internal caller → Reverse Proxy → ScrambleIQ App Host.
- ScrambleIQ App Host/Worker → Database.
- App-hosting nodes → observability and backup endpoints.

---

## 4) Trust Boundaries

### Boundary A: `workbench` (Operator/Control Zone)
- Contains privileged administrative tooling and offensive testing assets.
- Strong access control and audit requirements.

### Boundary B: `test-core` (Shared Core Services Zone)
- Hosts identity, DNS, observability, and foundational security services.
- Considered high-trust internal services boundary.

### Boundary C: `app-hosting` (Application Execution Zone)
- Hosts workload runtime and data services.
- Must consume core services through controlled, minimal interfaces.

### Boundary Rules
- Inter-boundary communication must be explicitly allow-listed.
- No unmanaged direct administrative access from outside `workbench`.
- Security simulation traffic must be constrained to approved scopes.

---

## 5) Failure Impact Model

| Failing Service | Immediate Impact | Downstream Impact |
|---|---|---|
| Firewall | Path disruption or policy bypass risk | Cross-zone operations become either unavailable or insecure |
| DNS | Name resolution failures | Automation, monitoring, and app connectivity failures |
| Time Synchronization | Clock drift | Auth issues, telemetry mis-correlation, TLS errors |
| Domain Controller | Identity/auth failures | Admin access and service account workflows disrupted |
| Jump Host | Loss of controlled operator ingress | Incident response and maintenance delays |
| Control Node | IaC/config execution blocked | Infrastructure drift and inability to apply changes |
| Wazuh Manager | Security event intake interruption | Detection coverage blind spots |
| Prometheus | Metrics and alerting outage | Degraded reliability operations |
| Grafana | Visualization unavailable | Slower triage despite metrics possibly still present |
| Caldera/Attack Box | Testing capability outage | Cannot validate defensive controls deterministically |
| Reverse Proxy | App entry point outage | Full user-facing application outage |
| Application Host | Core app runtime outage | Service unavailable despite proxy availability |
| Database | Data path outage | Application unusable and potential data integrity risk |
| Secret Management Process | Credential retrieval/update failures | Automation and service startup failures |
| Backup Execution | No new restore points | Increased recovery risk after incident/failure |

---

## 6) Deterministic Implementation Guidance

- Every service dependency must be declared in code (module variables, inventory groups, or role dependencies).
- Service startup ordering must follow dependency graph and be enforced in automation.
- Health checks for dependency services must gate downstream deployment tasks.
- All service definitions and changes must be traceable through Git commits and reviewed before apply.
- Optional/future services are excluded from Phase 1 pipelines by explicit feature flags or inventory scoping.
