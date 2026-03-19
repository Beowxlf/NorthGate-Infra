# Decision Log

## Purpose
Records architecture and delivery decisions that materially affect deterministic infrastructure implementation and operations.

## Decision Record Template
- **ID:** `NG-DEC-XXXX`
- **Date:** `YYYY-MM-DD`
- **Status:** proposed | accepted | superseded | retired
- **Phase:** roadmap phase number(s)
- **Context:** problem and constraints
- **Decision:** approved approach
- **Consequences:** expected benefits/tradeoffs
- **Related Docs/Code:** references to docs, modules, roles, workflows

## Entries

### NG-DEC-0001
- **Date:** 2026-03-19
- **Status:** accepted
- **Phase:** 0-1
- **Context:** The repository required a deterministic structure that cleanly separated infrastructure concerns.
- **Decision:** Adopt the three-layer model: provisioning (Terraform/OpenTofu), configuration (Ansible), application workflow.
- **Consequences:** Reduced ambiguity in ownership and execution ordering; improved reviewability.
- **Related Docs/Code:** `docs/01-architecture/system-overview.md`, `docs/02-infrastructure/service-catalog.md`.

### NG-DEC-0002
- **Date:** 2026-03-19
- **Status:** accepted
- **Phase:** 1
- **Context:** Environment sprawl and inconsistent naming increase configuration risk.
- **Decision:** Standardize naming conventions for compute, network, and storage as `ng-<env>-<role/segment>-<index>`.
- **Consequences:** Predictable identifiers and simpler automation targeting.
- **Related Docs/Code:** `docs/01-architecture/network-design.md`, `docs/02-infrastructure/compute.md`, `docs/02-infrastructure/storage.md`.

### NG-DEC-0003
- **Date:** 2026-03-19
- **Status:** accepted
- **Phase:** 2-5
- **Context:** Service implementation must align with phased roadmap to reduce integration risk.
- **Decision:** Map each catalog service to a roadmap phase and required dependencies before promotion.
- **Consequences:** Enables staged delivery with explicit prerequisites and validation gates.
- **Related Docs/Code:** `docs/02-infrastructure/service-catalog.md`, `docs/04-environments/*.md`.

### NG-DEC-0004
- **Date:** 2026-03-19
- **Status:** accepted
- **Phase:** 6-7
- **Context:** Deterministic infrastructure requires enforcement and proven recoverability, not only implementation intent.
- **Decision:** Treat CI policy enforcement and recovery drills as required deliverables before platform maturity.
- **Consequences:** Higher upfront process rigor, lower long-term operational risk.
- **Related Docs/Code:** `docs/05-operations/deployment-workflow.md`, `docs/05-operations/failure-recovery.md`.
