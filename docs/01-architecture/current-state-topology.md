# Current-State Topology (Authoritative Baseline)

## Scope and Time Reference
- Baseline date: 2026-03-19
- This document captures the **current** infrastructure topology before Phase 1 rebuild execution.

## Network State
- Current primary network: `10.10.100.0/24`
- Network model: **flat Layer-2/Layer-3 network** with no enforced production segmentation.
- Flat-network state is **temporary** and must not be treated as target architecture.

## Known Static Addresses
| System | Address | Status |
|---|---|---|
| iDRAC (physical host management) | `10.10.100.49` | Active and reachable (management-plane endpoint) |
| Domain Controller (DC + DNS) | `10.10.100.150` | Active service endpoint |

## Physical Host Role (HC)
- Physical host identifier: `HC`
- Current role: consolidated compute host for existing virtualized workloads.
- Current dependency pattern: multiple core/security services are co-resident or indirectly dependent on HC availability.
- Risk implication: HC outage causes multi-service impact due to consolidation.

## Current Logical Relationships
1. Endpoints and servers in the same `10.10.100.0/24` trust domain consume DNS/auth from DC (`10.10.100.150`).
2. Security and operations tooling (Wazuh, Caldera, TRMM) operate without enforced inter-zone isolation.
3. File-sharing workflows traverse the same flat network and share the same trust boundary.
4. Administrative access and service traffic are not strongly separated by network policy.

## Segmentation and Trust-Boundary Findings
- No deterministic zone-to-zone segmentation is currently enforced.
- Management-plane and data-plane traffic coexist in the same broad trust domain.
- East-west lateral movement resistance is limited.
- Monitoring and adversary tooling separation is policy-defined in target state but not currently enforced.

## Known Unknowns (Explicit)
- `UNKNOWN`: complete host-by-host MAC/IP inventory for all non-documented systems on `10.10.100.0/24`.
- `UNKNOWN`: comprehensive firewall/ACL rule inventory currently active between workloads.
- `UNKNOWN`: full service port exposure map for every host in current flat network.
- `UNKNOWN`: complete backup coverage status for all current-state services.

## Temporary-State Constraint
This topology is a migration starting point only. No new permanent dependencies may be added to the flat network model.
