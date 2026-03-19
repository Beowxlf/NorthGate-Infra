# Decision Log

This file tracks high-impact architectural and operational decisions.

## Decision Template
- **ID:** NG-DEC-XXXX
- **Date:** YYYY-MM-DD
- **Status:** proposed | accepted | superseded | retired
- **Context:** problem statement and constraints
- **Decision:** chosen approach
- **Consequences:** positive/negative outcomes
- **Related Changes:** PRs, modules, roles, or docs

## Entries

### NG-DEC-0001
- **Date:** 2026-03-19
- **Status:** accepted
- **Context:** Repository needed deterministic structure for local-lab IaC lifecycle.
- **Decision:** Adopt layered model (provisioning/configuration/application) with environment-specific promotion path `test-core -> workbench -> app-hosting`.
- **Consequences:** Clear execution flow and reduced ambiguity for human and AI contributors.
- **Related Changes:** Initial documentation standardization baseline.

### NG-DEC-0002
- **Date:** 2026-03-19
- **Status:** accepted
- **Context:** Inconsistent naming conventions increased risk of misconfiguration.
- **Decision:** Standardize naming across compute, network, and storage objects with `ng-<env>-<role/segment>-<index>` style patterns.
- **Consequences:** Improved predictability and easier automation validation.
- **Related Changes:** Architecture and infrastructure naming standard documents.
