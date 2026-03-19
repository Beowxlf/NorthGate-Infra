# Networking

## Networking Responsibilities by Layer

### Provisioning (Terraform/OpenTofu)
- Create environment segments and network interfaces.
- Configure route tables and firewall/security policy objects.
- Output stable addressing and DNS-relevant host records.

### Configuration (Ansible)
- Apply host firewall baselines.
- Configure resolver settings and service bind addresses.
- Enforce service-specific port exposure rules.

## Required Connectivity Paths
- `workbench` control node -> all managed nodes for configuration.
- all nodes -> DNS and time services in `test-core`.
- app hosts -> DB and proxy paths in `app-hosting`.
- all monitored nodes -> Wazuh/Prometheus endpoints.

## Addressing Standard
- CIDR allocations are environment-specific and non-overlapping.
- Static assignments are reserved for foundational services; dynamic pools for auxiliary nodes.
- All address assignments are declared as code inputs and must be reproducible.

## Security Segmentation Requirements
- Default deny between environment segments; explicit allow by service dependency.
- No direct unrestricted ingress to `app-hosting` management interfaces.
- Security test tooling traffic is constrained to approved windows and target scopes.
