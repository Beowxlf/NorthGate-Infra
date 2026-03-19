# AGENTS.md — NorthGate-Infra Repository Enforcement

## 1) Project Purpose
NorthGate-Infra defines and implements a reproducible infrastructure baseline for a segmented Blue Team lab using infrastructure-as-code and configuration-as-code.

The repository objective is deterministic build, deterministic rebuild, and deterministic change control across all environments.

## 2) Repository Structure and Ownership
The repository is organized into four execution layers with strict ownership boundaries:

- `terraform/` — infrastructure provisioning only (compute, network, storage, security controls, infrastructure dependencies).
- `ansible/` — host and service configuration only after infrastructure exists.
- `packer/` — image build pipelines and immutable base image definitions only.
- `docs/` — authoritative architecture, infrastructure, operations, and decision documentation.

No layer may absorb responsibilities assigned to another layer.

## 3) Mandatory Separation of Concerns
The following separation is mandatory and non-negotiable:

1. Terraform provisions resources and foundational infrastructure topology.
2. Ansible configures provisioned systems and deploys/configures services.
3. Packer builds reusable images consumed by provisioning workflows.

Prohibited patterns:
- Terraform running ad hoc service configuration that belongs to Ansible.
- Ansible creating foundational infrastructure that belongs to Terraform.
- Manual image drift outside Packer definitions.

## 4) Change Rules by Directory

### `docs/`
- Update documentation when architecture, infrastructure, dependency, or operational behavior changes.
- Current-state, target-state, and transition-state artifacts must remain consistent.
- Unknowns must be explicitly marked as `UNKNOWN`.

### `terraform/`
- Changes must map to documented architecture and environment model.
- Resource intent, environment scope, and dependency ordering must be explicit.
- No undocumented infrastructure behavior is permitted.

### `ansible/`
- Playbooks/roles must align to services defined in the service catalog and dependency model.
- Configuration must be idempotent and environment-scoped.
- Manual post-run “fixes” are prohibited unless documented as tracked exceptions.

### `packer/`
- Image definitions must be versioned, deterministic, and reproducible.
- Base image hardening/configuration decisions must be documented.
- Runtime patching that should exist in images must be captured back into Packer.

## 5) Reproducibility and Documentation Requirements
- All infrastructure and service state must be reproducible from repository code.
- Undocumented changes are prohibited.
- Out-of-band/manual changes require documented exception records and remediation plans to return to code-defined state.

## 6) Alignment Requirements
All changes must align with and reference:
1. Service catalog (`docs/02-infrastructure/service-catalog.md`)
2. Environment model (`docs/01-architecture/environment-model.md` and `docs/04-environments/`)
3. Dependency model (`docs/01-architecture/service-dependency-model.md`)

If a change conflicts with these artifacts, the change is blocked until documentation is updated in the same change set.

## 7) Constraints
- Do not assume any specific cloud provider unless explicitly documented and approved.
- Do not introduce new tools, platforms, or frameworks without written justification, scope impact, and integration plan.
- Do not rely on implicit defaults for security, networking, or identity behavior.

## 8) AI Output Contract (Required)
AI-generated outputs must be:
- Structured (clear headings, tables, ordered steps where applicable)
- Deterministic (explicit inputs, outputs, dependencies, and sequencing)
- Concrete (no vague wording such as “as needed”, “etc.”, or “best effort”)
- Traceable (mapped to documented services, environments, and dependencies)

Any AI output that is ambiguous, non-deterministic, undocumented, or out-of-scope must be treated as non-compliant.
