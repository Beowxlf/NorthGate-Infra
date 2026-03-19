# Statement of Purpose

## Mission
NorthGate-Infra is the single source of truth for building, securing, operating, and recovering the NorthGate on-premises platform using deterministic Infrastructure as Code (IaC).

The repository exists to ensure that any approved operator can rebuild platform environments from zero by executing versioned Terraform/OpenTofu, Ansible, and Packer workflows.

## System Contract
This repository must always provide the following guarantees:

1. **Rebuildability:** A new operator can provision and configure all supported environments from an empty virtualization substrate.
2. **Determinism:** Infrastructure outcomes are driven by Git state, not manual drift.
3. **Traceability:** Every architectural choice and operational procedure is documented, versioned, and reviewable.
4. **Separation of concerns:** Provisioning, configuration, and application layers remain distinct.
5. **Safety:** Every change follows controlled promotion and rollback procedures.

## Toolchain Boundary
NorthGate-Infra is intentionally constrained to:

- **Terraform/OpenTofu** for provisioning (VMs, network objects, storage primitives).
- **Ansible** for configuration (OS baselines, services, hardening, operational controls).
- **Packer** for machine image baselines used by provisioned nodes.

No additional orchestration platform is required for the baseline roadmap.

## Roadmap Alignment
Documentation and implementation are executed in the following phases:

- **Phase 0:** Baseline and documentation.
- **Phase 1:** Core IaC foundation.
- **Phase 2:** Core services (Domain Controller, Wazuh, control node).
- **Phase 3:** Observability (Prometheus, Grafana).
- **Phase 4:** Security validation (Caldera, attack simulation).
- **Phase 5:** Application hosting (ScrambleIQ stack).
- **Phase 6:** CI and workflow enforcement.
- **Phase 7:** Failure and recovery validation.

## Non-Goals
- This repository does not define cloud-managed platform dependencies.
- This repository does not include application feature design documents.
- This repository does not permit unmanaged, out-of-band infrastructure changes.
