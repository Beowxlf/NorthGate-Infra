# Current-State Service Matrix

## Scope and Time Reference
- Baseline date: 2026-03-19
- Purpose: deterministic mapping of current service hosting, dependencies, and IaC transition intent.

| Service | Hosting System (Current) | Purpose | Current Dependencies | Transition Disposition | IaC Transition Notes |
|---|---|---|---|---|---|
| Active Directory Domain Services | `DC` (`10.10.100.150`) | Centralized identity and authorization | DNS role, time sync, HC availability, flat network reachability | Rebuilt | Define as Tier-0 in Terraform/Ansible sequence; replacement must be validated before legacy DC retirement |
| Internal DNS | `DC` (`10.10.100.150`) | Internal name resolution | AD DS integration, HC availability, client reachability | Rebuilt | Migrate to code-defined DNS role with explicit zones/forwarders; cutover only after resolution parity checks |
| Wazuh (manager/indexer/dashboard stack) | `wazuh` host | Security telemetry, detection, and alerting | Agent traffic, DNS, time sync, storage, HC availability | Rebuilt | Recreate with deterministic topology and storage config; dual-ingest validation period required before cutover |
| MITRE Caldera | `caldera` host | Adversary emulation orchestration | DNS, operator access, target reachability, HC availability | Rebuilt | Recreate in isolated workbench architecture; prohibit new dependencies on legacy host |
| Tactical RMM (TRMM) | `trmm` host | Legacy remote management | Agent install base, admin connectivity | Removed | Freeze feature usage; uninstall agents only after replacement admin workflows are verified |
| File Share Service | `fileshare` host/system | Shared artifact and operations storage | AD auth (if joined), storage availability, network reachability | Rebuilt | Recreate with explicit ACL model and backup policy as code before decommissioning legacy share |

## Matrix Rules
1. “Rebuilt” means no in-place drift remediation; service is recreated through code-defined infrastructure/configuration.
2. “Removed” means service is decommissioned after documented replacement capability is operational.
3. Dependency changes must be reflected in both service catalog and dependency model before implementation.
