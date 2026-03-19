# Environment Model

## Purpose
This model defines environment intent, ownership boundaries, and promotion behavior for deterministic infrastructure delivery.

## Environment Definitions

| Environment | Primary Purpose | Mandatory Services | Change Cadence | Promotion Role |
|---|---|---|---|---|
| `test-core` | Foundational platform and shared services | Domain Controller, DNS, Wazuh, Prometheus, Grafana | Moderate | Baseline validation point |
| `workbench` | Operator tooling and security testing control plane | Jump host, control node, Caldera, attack tooling | Moderate-to-high | Operational tooling validation point |
| `app-hosting` | Application runtime and data services | Reverse proxy, app host, database, optional worker | High | Final delivery target |

## Boundary Rules
- `test-core` changes must not include app runtime deployment artifacts.
- `workbench` controls automation and security exercises but is not an app runtime environment.
- `app-hosting` consumes shared core services but does not host foundational identity or global observability control services.

## Promotion Model
1. Validate design and IaC in branch.
2. Apply and validate in `test-core`.
3. Promote tooling/security changes to `workbench`.
4. Promote compatible runtime changes to `app-hosting`.

## Environment State Principles
- Each environment has isolated variable/state inputs.
- Shared modules and roles are versioned and reused.
- Environment drift is remediated via IaC re-application, not manual edits.
