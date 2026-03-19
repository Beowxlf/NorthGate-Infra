# Current-State to Target-State Transition Model (Deterministic)

## Scope and Time Reference
- Baseline date: 2026-03-19
- Purpose: define unambiguous, service-by-service transition from current flat-network state to target architecture.

## Service Transition Mapping

| Service | Current State | Target State | Required Action | Dependency Order | Primary Transition Risks |
|---|---|---|---|---|---|
| AD DS (Domain Services) | Single DC on `10.10.100.150` in flat `10.10.100.0/24` | Code-defined Tier-0 identity service in `test-core` Core Services Zone | Rebuild + controlled migration of domain function | 1 | Authentication outage if DNS/time are inconsistent during cutover |
| Internal DNS | Co-hosted on current DC | Code-defined DNS aligned to Core Services Zone architecture | Rebuild + migrate clients | 2 (after AD baseline) | Name resolution failure causing broad service outage |
| File Share | Legacy `fileshare` host in flat network | Rebuilt file service in Core Services Zone with explicit ACL and backup controls | Rebuild + data migration | 3 (after AD/DNS) | Access-control mismatch or data permission regression |
| Wazuh | Legacy single-stack deployment on flat network | Rebuilt security stack in Monitoring/Security Zone | Rebuild + staged agent migration | 4 (after AD/DNS) | Logging visibility gap during agent cutover |
| Caldera | Legacy deployment with limited isolation | Rebuilt in `workbench` adversary-simulation boundary | Rebuild | 5 (after core auth/dns and baseline logging) | Uncontrolled traffic if isolation controls are incomplete |
| TRMM | Legacy tactical RMM in active use | Decommissioned (no target-state residency) | Decommission | 6 (after replacement admin/config workflows validated) | Loss of admin access if removed before replacement workflows are operational |

Dependency Order values are strict execution order; do not reorder without documented architecture change approval.

## Migration Sequencing Strategy

### Sequence 1 — Establish Core Identity and Name Services
1. Build target AD DS baseline via Terraform + Ansible in `test-core`.
2. Build target DNS service integrated with target AD model.
3. Validate authentication and DNS parity against required service accounts and host lookups.

### Sequence 2 — Rebuild Core Shared Service
4. Build target file-share service with explicit ACL and backup policy.
5. Migrate required data sets and validate access by role.

### Sequence 3 — Rebuild Security Visibility Plane
6. Build target Wazuh stack in monitoring/security boundary.
7. Enroll/migrate agents in controlled batches; maintain log continuity checkpoints per batch.

### Sequence 4 — Rebuild Controlled Adversary Capability
8. Build target Caldera deployment in workbench boundary.
9. Validate scoped targeting and telemetry capture paths.

### Sequence 5 — Remove Legacy Control Plane Component
10. Decommission TRMM only after replacement administration and configuration workflows are validated.

## Build-First and Remove-Later Rules

### Must Be Built First
- AD DS and DNS must be operational before any dependency service migration.
- Wazuh replacement must ingest required telemetry before legacy security monitoring is retired.
- Replacement administration/configuration workflows must be validated before TRMM removal.

### Cannot Be Removed Until Replacement Exists
- Current DC/DNS cannot be retired until target authentication + DNS are proven stable.
- Legacy Wazuh cannot be retired until target monitoring provides equivalent or better event coverage.
- TRMM cannot be removed until Ansible-based and documented admin procedures fully replace required functions.

## Breakage-Prevention Controls (Mandatory)

### Authentication Continuity
- Maintain valid authentication provider availability throughout AD/DNS transition.
- Execute cutover only after successful test logons for representative admin and service identities.

### Logging Continuity
- Operate temporary dual-ingest or overlap period during Wazuh migration.
- Do not decommission legacy ingestion until alert and retention checks pass for defined validation window.

### Control Access Continuity
- Preserve a documented administrative access path at all times during migration.
- Do not remove legacy remote-management capability until replacement access path is verified and exercised.

## Explicit Unknowns and Constraints
- `UNKNOWN`: complete current agent inventory and enrollment health by endpoint.
- `UNKNOWN`: full dataset size and access-pattern profile for file-share migration planning.
- `UNKNOWN`: exact current TRMM dependency surface across endpoints.

Unknowns do not block sequencing order, but they must be resolved before each affected service cutover checkpoint.
