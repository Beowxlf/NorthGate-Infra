# Core Services

## Purpose
Define the minimum viable core service layer required for stable identity, network control, automation management, and observability foundations across all lab environments.

---

## 1) Identity Services

### Service: Domain Controller (AD DS)
- **Purpose:** Provide centralized authentication, authorization, and policy control for users, hosts, and service accounts.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `test-core`.
- **Dependencies:** DNS, Time Synchronization, Firewall policy allowing domain protocols.
- **Failure Impact:** Host logins, service account authentication, policy enforcement, and domain joins fail.
- **Implementation Notes:**
  - Provision VM/network artifacts with Terraform/OpenTofu.
  - Configure AD DS role, OU baseline, and service accounts with Ansible.
  - Use Packer-built hardened base image to reduce post-provision drift.
- **Phase:** Phase 1.
- **Minimum Viable Version:** Single domain controller instance with documented recovery procedure; no HA requirement in Phase 1.

### Service: DNS
- **Purpose:** Resolve internal service names deterministically for all nodes and automation workflows.
- **Layer:** Infrastructure + Configuration.
- **Environment:** Primary in `test-core`; optional secondary in `workbench` (Phase 2).
- **Dependencies:** Firewall, Time Synchronization.
- **Failure Impact:** Automation, monitoring, and application connectivity degrade or fail due to unresolved names.
- **Implementation Notes:**
  - Define zone scope and forwarder policy in Git.
  - Enforce all service endpoints by FQDN in Ansible inventory and templates.
- **Phase:** Phase 1 (secondary/HA in Phase 2).
- **Minimum Viable Version:** One authoritative resolver with static internal zones for all mandatory services.

---

## 2) Network Control Services

### Service: Firewall
- **Purpose:** Establish trust boundaries between `test-core`, `workbench`, and `app-hosting`; enforce least-privilege transport.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `test-core` network edge/inter-segment path.
- **Dependencies:** None (bootstrap service), Time Synchronization.
- **Failure Impact:** Either overexposure (policy bypass) or service outages (blocked dependencies).
- **Implementation Notes:**
  - Manage policy objects declaratively with Terraform/OpenTofu where platform supports it.
  - Apply host/service-specific rulesets via Ansible for OS firewalls where required.
  - Maintain explicit allow-list for service ports and management channels.
- **Phase:** Phase 1.
- **Minimum Viable Version:** Segmented policy allowing only required east-west and north-south flows.

### Service: Time Synchronization
- **Purpose:** Maintain consistent clocks for Kerberos, certificates, telemetry correlation, and automated change traceability.
- **Layer:** Configuration.
- **Environment:** Time source in `test-core`; clients in all environments.
- **Dependencies:** Firewall path.
- **Failure Impact:** Authentication failures, invalid cert checks, unreliable logs/alerts.
- **Implementation Notes:**
  - Configure trusted internal NTP source and force all nodes to sync from it.
  - Alert on clock drift threshold breaches (Prometheus).
- **Phase:** Phase 1.
- **Minimum Viable Version:** One reliable internal NTP source with client enforcement across all managed nodes.

---

## 3) Management Services

### Service: Jump Host
- **Purpose:** Controlled operator entry point for administrative access, minimizing direct exposure of internal nodes.
- **Layer:** Infrastructure + Configuration + Image.
- **Environment:** `workbench`.
- **Dependencies:** Domain Controller, DNS, Firewall, Time Synchronization.
- **Failure Impact:** Manual break-glass operations and interactive maintenance are blocked.
- **Implementation Notes:**
  - Build hardened image with Packer.
  - Enforce MFA/credential policy through identity integration (as implemented in lab scope).
  - Restrict outbound paths to only required management destinations.
- **Phase:** Phase 1.
- **Minimum Viable Version:** Single bastion host with audited admin session policy.

### Service: Control Node
- **Purpose:** Executes Terraform/OpenTofu, Ansible, and image pipeline orchestration as the IaC control-plane endpoint.
- **Layer:** Infrastructure + Configuration + Image.
- **Environment:** `workbench`.
- **Dependencies:** Jump Host, DNS, Firewall, Secret Management, Time Synchronization.
- **Failure Impact:** Infrastructure changes, patching, and service reconfiguration cannot be executed reproducibly.
- **Implementation Notes:**
  - Keep toolchain versions pinned and versioned in repository docs.
  - Isolate SSH/API credentials to vaulted stores.
  - Treat as privileged asset with stricter hardening baseline.
- **Phase:** Phase 1.
- **Minimum Viable Version:** Single managed node with pinned toolchain and deterministic inventory state.

---

## 4) Observability Foundations

### Service: Prometheus
- **Purpose:** Central metrics collection and alert-rule evaluation for core and application services.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `test-core`.
- **Dependencies:** DNS, Firewall, Time Synchronization.
- **Failure Impact:** Loss of metrics visibility and delayed incident detection.
- **Implementation Notes:**
  - Define scrape jobs and recording rules as versioned configuration.
  - Include exporters for node, service, and application process health.
- **Phase:** Phase 1.
- **Minimum Viable Version:** Single instance scraping all mandatory nodes/services with baseline availability alerts.

### Service: Grafana
- **Purpose:** Visualize telemetry and support operational troubleshooting and readiness reporting.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `test-core`.
- **Dependencies:** Prometheus, DNS, Firewall, Time Synchronization.
- **Failure Impact:** Metrics remain available but operator situational awareness and triage speed degrade.
- **Implementation Notes:**
  - Keep dashboards in Git (JSON/provisioning files).
  - Separate admin credentials from runtime service credentials.
- **Phase:** Phase 1.
- **Minimum Viable Version:** Core dashboards for host health, service health, and dependency availability.

### Service: Wazuh Foundation (Manager + Agents)
- **Purpose:** Provide host-based security telemetry as a baseline control integrated with observability.
- **Layer:** Infrastructure + Configuration.
- **Environment:** Manager in `test-core`; agents in all environments.
- **Dependencies:** DNS, Firewall, Time Synchronization, Storage.
- **Failure Impact:** Endpoint detection and security visibility gaps.
- **Implementation Notes:**
  - Auto-enroll agents via Ansible role logic.
  - Forward key security indicators into shared operations dashboards.
- **Phase:** Phase 1.
- **Minimum Viable Version:** Manager operational plus agent coverage on all Phase 1 hosts.
