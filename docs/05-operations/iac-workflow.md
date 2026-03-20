# IaC Workflow (Phase 1)

## Purpose and Scope
This document defines the deterministic Phase 1 infrastructure-as-code (IaC) workflow for NorthGate-Infra using:
- **Packer** for immutable image creation,
- **Terraform** for infrastructure provisioning,
- **Ansible** for host and service configuration.

The workflow applies to all Phase 1 environment runs and must align with:
- Service catalog (`docs/02-infrastructure/service-catalog.md`),
- Environment model (`docs/01-architecture/environment-model.md`, `docs/04-environments/`),
- Dependency model (`docs/01-architecture/service-dependency-model.md`).

## Authoritative Control Model
1. **Git is the single source of truth** for infrastructure, configuration, and operational workflow definitions.
2. **No manual runtime changes are allowed** on provisioned systems. Any required change must be implemented through Packer, Terraform, or Ansible and committed to Git.
3. **Execution is deterministic**: identical commit + identical inputs must produce equivalent infrastructure and configuration state.
4. **Layer boundaries are enforced**:
   - Packer builds reusable machine images,
   - Terraform provisions VM and foundational infrastructure,
   - Ansible configures provisioned hosts and services.

## Build Flow (Phase 1)

### 1) Packer -> Image
**Input**
- Packer template definitions,
- Base image source reference,
- Hardened/image baseline requirements from configuration documentation.

**Execution**
- Run Packer build for the target environment scope.
- Produce versioned immutable image artifact.

**Output**
- Image identifier (image ID/name/version) recorded for Terraform input.

### 2) Terraform -> VM
**Input**
- Terraform module and environment variable definitions,
- Image identifier produced by Packer,
- Environment target (for example: `test-core`, `workbench`, `app-hosting`).

**Execution**
- Run Terraform init/validate/plan.
- Run controlled Terraform apply using approved plan.

**Output**
- Provisioned VM(s), networking attachments, and required infrastructure dependencies.
- Terraform state reflecting actual infrastructure resources.

### 3) Ansible -> Configuration
**Input**
- Terraform outputs (host/IP/connection metadata),
- Ansible inventory derived from environment and provisioned targets,
- Role/playbook set mapped to service catalog and dependency model.

**Execution**
- Run Ansible playbooks in documented service dependency order.
- Apply host baselines and service configuration idempotently.

**Output**
- Configured hosts/services with expected Phase 1 baseline state.
- Play recap and logs proving configuration convergence.

## Required Execution Order
Phase 1 run sequence is mandatory and must not be reordered:

1. **Select target commit and target environment**.
2. **Build image with Packer**.
3. **Update Terraform inputs with image artifact reference**.
4. **Provision VM and infrastructure dependencies with Terraform**.
5. **Generate/refresh inventory from Terraform outputs**.
6. **Apply configuration with Ansible**.
7. **Run validation checks (infrastructure, configuration, idempotency)**.
8. **Record operation results and artifact references**.

If any step fails, stop progression, remediate through code changes, and re-run from the appropriate earlier stage.

## Step-by-Step Execution Guide

### Step 0 - Pre-flight controls
1. Checkout approved Git commit/branch for the operation.
2. Confirm required documentation consistency for service/environment/dependency scope.
3. Confirm no uncommitted local changes.

### Step 1 - Build immutable image (Packer)
1. Initialize Packer plugins if required.
2. Run Packer validation for the image definition.
3. Execute Packer build and capture resulting image ID/version.
4. Persist image metadata in operation record.

### Step 2 - Provision VM (Terraform)
1. Initialize Terraform working directory.
2. Run Terraform formatting and validation checks.
3. Run Terraform plan using the Packer image ID/version as input.
4. Review plan output for scope and dependency correctness.
5. Execute Terraform apply from the reviewed plan.
6. Capture Terraform outputs required by Ansible (IP/hostname/connection values).

### Step 3 - Configure VM (Ansible)
1. Render or update inventory from Terraform outputs.
2. Run Ansible syntax/lint checks for targeted playbooks.
3. Run Ansible playbook for Phase 1 baseline and service roles.
4. Capture play recap and changed/ok/fail counts.

### Step 4 - Validate result
1. Validate VM existence and platform state.
2. Validate expected configuration and service state.
3. Re-run Ansible to validate idempotency.
4. Store run artifacts (plan output, apply output, ansible logs, validation evidence).

## Validation Steps

### A) Confirm VM exists
A VM existence validation must include all of the following:
1. Terraform state includes expected VM resource address(es).
2. Terraform output values return expected host identity/connectivity values.
3. Infrastructure query (provider/API/CLI) confirms VM in expected lifecycle state (running/available).

Pass criteria: all three checks match expected environment model and naming.

### B) Confirm configuration applied
Configuration validation must include all of the following:
1. Ansible play recap returns `failed=0` and `unreachable=0`.
2. Target services required by the service catalog are installed/configured/running as defined.
3. Host baseline controls are present per configuration standards.

Pass criteria: no failed tasks and all required service checks pass.

### C) Confirm idempotency
Idempotency validation must include all of the following:
1. Re-run the same Ansible playbook against the same target.
2. Confirm second run reports zero unintended changes for managed resources (expected `changed=0` for stable target state).
3. If changes are reported, treat as non-compliant drift and remediate through code changes.

Pass criteria: repeat run converges without additional unintended modifications.

## Destruction and Rebuild Process

### Controlled destruction
1. Select target environment and confirm destruction approval.
2. Export or preserve required operational evidence/state artifacts.
3. Run Terraform destroy for the environment scope.
4. Verify all managed infrastructure resources are removed.
5. Preserve logs and destroy output in change record.

### Deterministic rebuild
1. Use approved Git commit (or newer approved commit) as rebuild source.
2. Rebuild image with Packer (or reference approved immutable image built from that commit).
3. Re-run Terraform apply to recreate VM/infrastructure.
4. Re-run Ansible configuration in required dependency order.
5. Execute full validation suite (existence, configuration, idempotency).

Rebuild is complete only when validation checklist passes without exception.

## Operational Constraints (Mandatory)
1. **Manual changes are prohibited** on provisioned resources (configuration, packages, service settings, network/security settings).
2. **Git is authoritative**: all intended state changes must be represented as reviewed commits.
3. **Drift response requirement**: detected drift must be corrected through repository code and rerun; not by direct/manual patching.
4. **Undocumented behavior is non-compliant**: if workflow, dependency, or service behavior changes, documentation updates are required in the same change set.

## Validation Checklist (Run Completion Gate)

### Infrastructure gate
- [ ] Packer build completed and produced versioned image artifact.
- [ ] Terraform plan reviewed and approved for expected scope.
- [ ] Terraform apply completed without errors.
- [ ] VM resource present in Terraform state and provider query.

### Configuration gate
- [ ] Ansible playbook run completed with `failed=0` and `unreachable=0`.
- [ ] Required Phase 1 services are in expected state per service catalog.
- [ ] Baseline controls applied per configuration standards.

### Idempotency gate
- [ ] Second Ansible run completed.
- [ ] Second run shows no unintended changes (`changed=0` for stable state).
- [ ] Any detected drift was remediated via Git commit and rerun.

### Documentation and traceability gate
- [ ] Change references service catalog, environment model, and dependency model artifacts.
- [ ] Run evidence archived (Packer output, Terraform plan/apply output, Ansible logs, validation notes).
- [ ] No manual/untracked changes were introduced.
