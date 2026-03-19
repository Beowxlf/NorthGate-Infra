# Security Services

## Scope
This document defines the detection, adversary simulation, and attack-testing service layer for the NorthGate lab, including integration requirements with observability systems.

---

## 1) Detection Services

### Service: Wazuh Manager Stack
- **Purpose:** Centralize endpoint security telemetry, apply detection rules, and support security monitoring workflows.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `test-core`.
- **Dependencies:** DNS, Time Synchronization, Firewall, persistent storage.
- **Failure Impact:** Detection pipeline interruption; endpoint security events not correlated centrally.
- **Implementation Notes:**
  - Provision compute/storage with Terraform/OpenTofu.
  - Configure manager/indexer/dashboard and rule sets with Ansible.
  - Keep local retention policy aligned with lab storage constraints.
- **Phase:** Phase 1.

### Service: Wazuh Agents
- **Purpose:** Collect host events (process, file integrity, auth, and security logs) from managed nodes.
- **Layer:** Configuration.
- **Environment:** All nodes across `test-core`, `workbench`, `app-hosting`.
- **Dependencies:** Wazuh Manager, DNS, Firewall, Time Synchronization.
- **Failure Impact:** Per-host blind spots; reduced confidence in attack validation results.
- **Implementation Notes:**
  - Agent deployment is mandatory in base host configuration roles.
  - Enrollment and key rotation procedures must be automated.
- **Phase:** Phase 1.

### Service Interaction: Wazuh ↔ Prometheus/Grafana
- **Purpose:** Ensure security and operational telemetry are correlated in a shared troubleshooting context.
- **Layer:** Configuration.
- **Environment:** `test-core`.
- **Dependencies:** Wazuh stack, Prometheus, Grafana.
- **Failure Impact:** Security and reliability signals remain siloed, increasing mean-time-to-diagnose.
- **Implementation Notes:**
  - Expose health and pipeline metrics from Wazuh components.
  - Surface security-status dashboards in Grafana for operational teams.
- **Phase:** Phase 1.

---

## 2) Adversary Simulation Services

### Service: MITRE Caldera
- **Purpose:** Run controlled adversary emulation aligned to ATT&CK techniques for validating defensive controls.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `workbench` management zone.
- **Dependencies:** DNS, Firewall segmentation, Time Synchronization, access to selected targets.
- **Failure Impact:** Inability to perform repeatable adversary emulation and control validation.
- **Implementation Notes:**
  - Limit operator access through Jump Host pathways.
  - Version operation profiles and plugins in repository-controlled configuration.
  - Explicitly scope allowed target ranges to prevent uncontrolled execution.
- **Phase:** Phase 1.

### Service: Attack Box
- **Purpose:** Dedicated operator host for executing approved offensive test workflows against lab targets.
- **Layer:** Infrastructure + Configuration + Image.
- **Environment:** `workbench`.
- **Dependencies:** Jump Host, DNS, Firewall rules, Time Synchronization.
- **Failure Impact:** Security testing procedures become ad hoc or are blocked.
- **Implementation Notes:**
  - Build from hardened, repeatable Packer image.
  - Enforce strict network egress/ingress restrictions.
  - Log all operator sessions and tooling actions where feasible.
- **Phase:** Phase 1.

---

## 3) Attack Testing Services

### Service Group: Detection Validation Pipeline
- **Purpose:** Validate that simulated attacks are detected by Wazuh and reflected in monitoring channels.
- **Layer:** Cross-layer (Security + Observability + Configuration).
- **Environment:** Source in `workbench`, detections in `test-core`, targets across all environments.
- **Dependencies:** MITRE Caldera, Attack Box, Wazuh stack, Wazuh agents, Prometheus/Grafana, DNS, Firewall.
- **Failure Impact:** No deterministic verification that detection engineering is effective.
- **Implementation Notes:**
  - Maintain test scenarios as version-controlled runbooks.
  - Define expected detection outcomes per scenario and verify automatically where possible.
- **Phase:** Phase 2 for automation depth; Phase 1 for manual validation capability.

---

## 4) Optional Future Security Tooling

### Service: Case Management Platform (Future)
- **Purpose:** Track incidents, investigations, and remediation tasks from security events.
- **Layer:** Infrastructure + Configuration.
- **Environment:** `test-core` or `workbench`.
- **Dependencies:** Wazuh, identity service, backup strategy, DNS, Firewall.
- **Failure Impact:** No impact to baseline detections; impacts investigation workflow maturity.
- **Implementation Notes:**
  - Integrate only after Phase 1 detection baseline is stable.
  - Must support data export/backup and role-based access controls.
- **Phase:** Future-state.

### Service: Analysis/Enrichment Tooling (Future)
- **Purpose:** Add enrichment pipelines for alerts and forensic triage support.
- **Layer:** Configuration/Application-support.
- **Environment:** `workbench` or `test-core`.
- **Dependencies:** Wazuh event feeds, observability data sources.
- **Failure Impact:** Reduced analyst efficiency; baseline operation remains functional.
- **Implementation Notes:**
  - Introduce only with explicit integration contracts and retention policies.
- **Phase:** Future-state.
