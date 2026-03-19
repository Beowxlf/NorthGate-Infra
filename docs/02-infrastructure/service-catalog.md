# Service Catalog

## Scope
This catalog defines the mandatory and optional services required to implement the NorthGate lab environments (`test-core`, `workbench`, `app-hosting`) as deterministic infrastructure managed from Git.

## Service Inventory

| Service | Category | Purpose | Environment Placement | Dependencies | Mandatory | Future IaC Owner Layer |
|---|---|---|---|---|---|---|
| Domain Controller (AD DS) | Core Infrastructure | Central identity provider for user, host, and service authentication/authorization. | `test-core` | DNS, Time Synchronization, Firewall | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| DNS Resolver/Authoritative Service | Core Infrastructure | Name resolution for all internal services and host-to-service communication. | `test-core` (primary), optional secondary in `workbench` | Firewall, Time Synchronization | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| Firewall Gateway | Core Infrastructure | Enforces inter-environment segmentation and egress/ingress policy boundaries. | `test-core` edge and inter-segment routing path | None (foundational), Time Synchronization | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| Jump Host (Bastion) | Core Infrastructure | Controlled administrative entry point for operators and automation troubleshooting. | `workbench` | Domain Controller, DNS, Firewall, Time Synchronization | Yes | Mixed (Terraform/OpenTofu + Ansible + Packer) |
| Control Node (IaC/Automation Orchestrator) | Core Infrastructure | Runs Terraform/OpenTofu, Ansible, and pipeline tasks against all environments. | `workbench` | DNS, Firewall, Jump Host, Secret Management, Time Synchronization | Yes | Mixed (Terraform/OpenTofu + Ansible + Packer) |
| Time Synchronization (NTP/Chrony) | Core Infrastructure | Maintains consistent time for Kerberos, TLS validation, logging correlation, and alerting. | `test-core` source; clients in all environments | Firewall | Yes | Ansible |
| Wazuh Manager/Indexer/Dashboard | Observability & Monitoring | Centralized security event collection, correlation, and detection management. | `test-core` | DNS, Time Synchronization, Firewall, Storage, Domain Controller (for auth integration if enabled) | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| Wazuh Agent | Observability & Monitoring | Host-based telemetry and detection endpoint for servers across environments. | All managed nodes in `test-core`, `workbench`, `app-hosting` | Wazuh Manager, DNS, Time Synchronization, Firewall | Yes | Ansible |
| Prometheus | Observability & Monitoring | Metrics scraping and alert-rule execution for platform and service health. | `test-core` | DNS, Time Synchronization, Firewall | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| Grafana | Observability & Monitoring | Operational dashboards and security/infra visualization over metrics and logs. | `test-core` | Prometheus, DNS, Time Synchronization, Firewall | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| MITRE Caldera Server | Security & Adversary Simulation | Controlled adversary emulation to validate detections and response paths. | `workbench` (management), reachable to controlled targets | DNS, Firewall, Time Synchronization, Domain identities (if domain tests required) | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| Attack Box | Security & Adversary Simulation | Operator endpoint used to execute offensive validation scenarios in isolated scope. | `workbench` | DNS, Firewall, Jump Host, Time Synchronization | Yes | Mixed (Terraform/OpenTofu + Ansible + Packer) |
| Case Management / Analysis Tooling | Security & Adversary Simulation | Optional incident tracking and investigative workflow support. | `test-core` or `workbench` | Wazuh, Prometheus/Grafana, DNS, Firewall | No (Future) | Mixed |
| Reverse Proxy | Application Hosting | Entry point for ScrambleIQ HTTP/S traffic; routes requests to application runtime. | `app-hosting` | DNS, Firewall, Time Synchronization, Secret Management | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| Application Host (ScrambleIQ Runtime) | Application Hosting | Runs ScrambleIQ service logic in test environment. | `app-hosting` | Reverse Proxy, Database, Container Runtime, DNS, Time Synchronization, Secret Management | Yes | Mixed (Terraform/OpenTofu + Ansible + Packer) |
| Database Service | Application Hosting | Persistent data store required by ScrambleIQ application state. | `app-hosting` | DNS, Time Synchronization, Storage, Backup Strategy, Secret Management, Firewall | Yes | Mixed (Terraform/OpenTofu + Ansible) |
| Worker Service (Optional) | Application Hosting | Asynchronous/background job execution for ScrambleIQ workloads. | `app-hosting` | Application Host, Database, Container Runtime, DNS, Time Synchronization | No (Phase 2) | Mixed (Terraform/OpenTofu + Ansible) |
| Container Runtime | Application Hosting | Standardized execution environment for application and optional worker containers. | `app-hosting` | OS baseline image, Storage, Time Synchronization | Yes | Ansible + Packer |
| File Services (SMB/NFS or equivalent internal share) | Supporting Services | Shared storage for configs, artifacts, and controlled data exchange where required. | `test-core` (or dedicated infra node) | DNS, Firewall, Backup Strategy, Time Synchronization, Domain Controller (if ACL integration) | Phase 2 | Mixed (Terraform/OpenTofu + Ansible) |
| Backup Service/Policy Execution | Supporting Services | Scheduled backups and restore points for AD, DB, configuration state, and telemetry data. | Cross-environment policy; backup target in `test-core` | Storage, DNS, Time Synchronization, Secret Management, Firewall | Yes | Ansible |
| Secret Management Approach (Vaulted files + Ansible Vault baseline) | Supporting Services | Protects credentials, tokens, and sensitive variables used by automation and services. | Control-plane process anchored in `workbench` control node | Control Node, Backup Strategy, Access Controls, Time Synchronization | Yes | Ansible |

## Implementation Phasing

- **Phase 1 (mandatory platform viability):** Domain Controller, DNS, Firewall, Jump Host, Control Node, Time Synchronization, Wazuh stack + agents, Prometheus, Grafana, MITRE Caldera, Attack Box, Reverse Proxy, Application Host, Database, Container Runtime, Backup Strategy, Secret Management.
- **Phase 2 (scale and maturity):** Worker Service, File Services, DNS secondary/high-availability variants, expanded observability retention tiers.
- **Future-state (optional expansion):** Case management/analysis tooling, advanced SOAR-style integration points.

## Ownership Boundary Notes

- **Terraform/OpenTofu:** Node/network primitives, subnet and firewall objects, VM lifecycle, disk/network attachments.
- **Packer:** Reusable base images for jump host, control node, attack box, and app host OS baselines.
- **Ansible:** Service installation, hardening, runtime configuration, user/group policy, backup jobs, and operational runbooks-as-code.
- **Mixed:** Any service requiring both resource provisioning and post-provision configuration.
