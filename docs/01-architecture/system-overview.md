# System Overview

## Architecture Summary
NorthGate is an on-premises multi-environment infrastructure platform built through phased delivery. The architecture uses strict layer separation so that platform lifecycle is reproducible and auditable.

## Infrastructure Layers

### 1) Provisioning Layer (Terraform/OpenTofu)
Responsibilities:
- Define and create environment network topology.
- Provision VM, network interface, and storage resources.
- Export outputs consumed by configuration automation.

### 2) Configuration Layer (Ansible)
Responsibilities:
- Apply baseline host configuration and hardening.
- Install and configure platform services.
- Enforce service dependencies and operational policies.

### 3) Application Layer (ScrambleIQ hosting workflow)
Responsibilities:
- Deploy application runtime components to prepared hosts.
- Bind runtime to configured database, reverse proxy, and secrets.
- Validate runtime health post-deployment.

## Logical Service Domains
- **Core Infrastructure:** Domain services, DNS, firewall policy, control access.
- **Observability:** Wazuh, Prometheus, Grafana.
- **Security Validation:** Caldera and controlled adversary simulation workflows.
- **Application Hosting:** ScrambleIQ reverse proxy, app runtime, database, optional workers.

## Roadmap-to-Architecture Mapping
- **Phase 0-1:** Layer model, naming conventions, foundational module/role structure.
- **Phase 2:** Core identity and security telemetry services.
- **Phase 3:** Metrics observability and dashboards.
- **Phase 4:** Adversary simulation for security effectiveness.
- **Phase 5:** Application hosting stack integration.
- **Phase 6:** CI enforcement across all layers.
- **Phase 7:** Failure and recovery verification.
