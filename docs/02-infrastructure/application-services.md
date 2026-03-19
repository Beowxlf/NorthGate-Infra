# Application Services (ScrambleIQ Test Hosting)

## Scope
Define the mandatory and optional services required to host ScrambleIQ in the `app-hosting` environment, while maintaining separation from shared infrastructure services.

---

## 1) Infrastructure Services vs Application Services

### Shared Infrastructure Services (not application-specific)
- DNS
- Firewall segmentation and access control
- Domain/identity services
- Time synchronization
- Central monitoring and security telemetry (Prometheus, Grafana, Wazuh)
- Backup policy framework
- Secret management baseline

These services are prerequisites supplied by core layers and must be consumed by the application stack, not re-implemented inside `app-hosting`.

### Application Services (ScrambleIQ-specific)
- Reverse Proxy
- Application Host runtime
- Database
- Optional worker service
- Container runtime support

---

## 2) ScrambleIQ Required Service Definitions

### Service: Reverse Proxy
- **Purpose:** Terminates inbound HTTP/S and routes requests to ScrambleIQ runtime endpoints.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `app-hosting`.
- **Dependencies:** DNS record, Firewall rules, TLS certificate material from secret management, Time Synchronization.
- **Failure Impact:** External/internal clients cannot reliably reach ScrambleIQ application endpoints.
- **Implementation Notes:**
  - Provision host/network resources with Terraform/OpenTofu.
  - Configure virtual hosts/routes, TLS, and hardening via Ansible.
  - Keep route definitions and headers policy versioned in Git.
- **Phase:** Phase 1.

### Service: Application Host (ScrambleIQ Runtime)
- **Purpose:** Executes ScrambleIQ web/API application workloads for functional testing.
- **Layer:** Application + Configuration + Image.
- **Environment:** `app-hosting`.
- **Dependencies:** Reverse Proxy, Database, Container Runtime, DNS, Firewall, Secret Management, Time Synchronization.
- **Failure Impact:** Core application functionality unavailable.
- **Implementation Notes:**
  - Build baseline runtime image with Packer where practical.
  - Deploy application configuration and runtime parameters with Ansible.
  - Keep environment-variable contract explicit and versioned.
- **Phase:** Phase 1.

### Service: Database
- **Purpose:** Persistent data storage for ScrambleIQ state and transactions.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `app-hosting`.
- **Dependencies:** Storage, DNS, Firewall, Time Synchronization, Secret Management, Backup service.
- **Failure Impact:** Data access failure, potential data loss risk, and application outage.
- **Implementation Notes:**
  - Define initialization schema/bootstrap process as code.
  - Enforce non-default credentials through vaulted secrets.
  - Apply backup and restore test procedures as mandatory controls.
- **Phase:** Phase 1.

### Service: Container Runtime
- **Purpose:** Standard execution substrate for ScrambleIQ services and optional workers.
- **Layer:** Configuration + Image.
- **Environment:** `app-hosting`.
- **Dependencies:** OS baseline, storage provisioning, firewall and kernel/network settings.
- **Failure Impact:** Application and worker services cannot start.
- **Implementation Notes:**
  - Install and harden runtime via Ansible roles.
  - Optionally pre-bake runtime prerequisites with Packer.
- **Phase:** Phase 1.

### Service: Worker Service (Optional)
- **Purpose:** Handles asynchronous/background tasks (queues, scheduled jobs, heavy processing).
- **Layer:** Application + Configuration.
- **Environment:** `app-hosting`.
- **Dependencies:** Application Host contract, Database, Container Runtime, DNS, Time Synchronization.
- **Failure Impact:** Background jobs delayed or lost; interactive application may continue partially.
- **Implementation Notes:**
  - Introduce only if ScrambleIQ workload model requires asynchronous processing.
  - Define queue semantics and retry policy before activation.
- **Phase:** Phase 2.

---

## 3) Placement Model in `app-hosting`

- **Edge/Application Entry:** Reverse Proxy
- **Application Runtime Tier:** ScrambleIQ application host container(s)
- **Data Tier:** Dedicated database service
- **Optional Async Tier:** Worker service container(s)
- **Cross-cutting:** Wazuh agent, node metrics exporter, backup agent/hooks, secret injection path

This placement keeps application lifecycle independent from core identity/security/monitoring services while preserving mandatory dependencies on those shared capabilities.

---

## 4) Minimum Viable Application Hosting (Phase 1)

1. Reverse Proxy operational with deterministic DNS name and TLS config.
2. Application host running ScrambleIQ in containerized runtime.
3. Database provisioned, initialized, and reachable only through least-privilege network policy.
4. Observability hooks active (metrics + security agent).
5. Backup policy applied to database and essential application configuration.
6. Secrets managed through repository-defined secret management approach (no plaintext credentials in Git).
