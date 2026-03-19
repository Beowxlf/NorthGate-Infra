# Current-State Infrastructure Inventory (Authoritative Baseline)

## Scope and Time Reference
- Baseline date: 2026-03-19
- Objective: enumerate currently known systems/services and their transition disposition.

| Hostname / System | Role | OS | Purpose | Current Status | Disposition |
|---|---|---|---|---|---|
| `DC` (`10.10.100.150`) | Active Directory Domain Controller + DNS | Windows Server 2022 | Authentication, directory services, internal DNS | Active; critical dependency in flat network | Rebuild |
| `wazuh` | Security monitoring platform | Linux (`UNKNOWN` distro/version) | SIEM/event collection and security analytics | Active in current environment | Rebuild |
| `caldera` | Adversary emulation server | Linux (`UNKNOWN` distro/version) | Controlled adversary simulation and detection validation | Active in current environment | Rebuild |
| `trmm` | Tactical RMM platform | Linux (`UNKNOWN` distro/version) | Legacy remote management footprint | Active legacy service; migration-only support | Remove |
| `fileshare` | File-sharing service | OS `UNKNOWN` | Artifact exchange and operational file storage | Active in current environment | Rebuild |

## Inventory Constraints
- This inventory defines the minimum required baseline for Phase 1 planning.
- Any additional active systems not listed here are out-of-baseline and must be added before related IaC implementation.
