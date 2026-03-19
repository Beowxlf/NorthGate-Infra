# test-core Environment

## Purpose
`test-core` is the foundational environment for identity, shared service control plane, and base observability.

## Mandatory Services
- Domain Controller and DNS.
- Wazuh manager stack.
- Prometheus and Grafana.

## Responsibilities
- Provide identity and naming services consumed by all other environments.
- Host central monitoring and security telemetry services.
- Act as first target for foundational IaC validation.

## Inputs and Outputs
- **Inputs:** core Terraform/OpenTofu modules, Ansible baseline roles, service role vars.
- **Outputs:** reachable identity/DNS endpoints, telemetry endpoints, validated baseline for promotion.

## Phase Alignment
- Primary implementation in phases 2-3.
- Hardened and validated through phases 6-7.
