# Service Catalog

## Catalog Purpose
Defines the authoritative list of infrastructure services, their ownership layer, dependencies, and roadmap phase.

## Service Matrix

| Service | Environments | Primary Responsibility | Depends On | IaC Ownership | Roadmap Phase |
|---|---|---|---|---|---|
| Domain Controller (AD DS) | `test-core` | Central identity and directory services | DNS, time, firewall policy | Terraform/OpenTofu + Ansible | 2 |
| DNS | `test-core` (+ clients everywhere) | Internal name resolution | network, time | Terraform/OpenTofu + Ansible | 2 |
| Control Node | `workbench` | Executes Terraform/OpenTofu and Ansible workflows | DNS, network reachability, secrets baseline | Terraform/OpenTofu + Ansible + Packer | 2 |
| Wazuh Manager Stack | `test-core` | Security telemetry aggregation and detection | DNS, storage, time | Terraform/OpenTofu + Ansible | 2 |
| Wazuh Agents | all | Endpoint telemetry and log forwarding | Wazuh manager, DNS | Ansible | 2 |
| Prometheus | `test-core` | Metrics collection and alert evaluation | DNS, service discovery endpoints | Terraform/OpenTofu + Ansible | 3 |
| Grafana | `test-core` | Dashboarding and observability visualization | Prometheus, DNS | Terraform/OpenTofu + Ansible | 3 |
| Caldera | `workbench` | Controlled adversary simulation orchestration | DNS, policy-approved target reachability | Terraform/OpenTofu + Ansible | 4 |
| Attack Simulation Host | `workbench` | Executes security validation scenarios | Caldera, network policy | Terraform/OpenTofu + Ansible + Packer | 4 |
| Reverse Proxy | `app-hosting` | Entry point routing and TLS termination for app traffic | DNS, certificates/secrets, app runtime | Terraform/OpenTofu + Ansible | 5 |
| ScrambleIQ Runtime Host | `app-hosting` | Executes application service workload | reverse proxy, DB, DNS | Terraform/OpenTofu + Ansible + Packer | 5 |
| Database | `app-hosting` | Persistent application data | storage, backup policy, DNS | Terraform/OpenTofu + Ansible | 5 |
| Optional Worker | `app-hosting` | Background task execution | app runtime, DB | Terraform/OpenTofu + Ansible | 5 |

## Layer Responsibility Rules
- Provisioning defines existence and connectivity of infrastructure resources.
- Configuration defines service installation and policy-compliant runtime behavior.
- Application workflow defines deployment sequence and runtime release state.
