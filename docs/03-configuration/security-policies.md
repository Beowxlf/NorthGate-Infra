# Security Policies (Phase 8 Policy-as-Code)

## Scope and Alignment
This policy applies to all Linux hosts in all NorthGate environments (`test-core`, `staging`, `production`) and is enforced by `ansible/roles/hardening`.  
Alignment references:
1. Service catalog: `docs/02-infrastructure/service-catalog.md`
2. Environment model: `docs/01-architecture/environment-model.md`, `docs/04-environments/`
3. Dependency model: `docs/01-architecture/service-dependency-model.md`

## Enforceable Baseline Controls

### 1) Authentication and SSH
| Control ID | Required state | Enforcement source |
|---|---|---|
| SEC-SSH-001 | `PermitRootLogin no` | `hardening_ssh_settings` |
| SEC-SSH-002 | `PasswordAuthentication no` | `hardening_ssh_settings` |
| SEC-SSH-003 | `PubkeyAuthentication yes` | `hardening_ssh_settings` |
| SEC-SSH-004 | Empty password auth disabled | `hardening_ssh_settings` |
| SEC-SSH-005 | `MaxAuthTries 3` | `hardening_ssh_settings` |

### 2) Allowed Services
Allowed runtime services for Linux managed hosts:
- `ssh`
- `cron`
- `rsyslog`
- `wazuh-agent`

Disallowed services (must be disabled/stopped):
- `telnet`
- `tftp`
- `avahi-daemon`
- `cups`

### 3) Required Ports (Host Firewall Allow-List)
Inbound TCP:
- `22` (SSH administration)
- `1514` (Wazuh events)
- `1515` (Wazuh enrollment)
- `55000` (Wazuh API)

Inbound UDP:
- `53` (DNS service traffic where applicable)

Default policy: deny all other inbound traffic.

### 4) Least-Privilege and Access Model
- Interactive operator account: `ops` (privileged group mapped by OS family).
- Service accounts must use non-interactive shell (`/usr/sbin/nologin` by default).
- Root direct remote authentication is prohibited.

### 5) Credential and Secret Handling
- Hardcoded credentials in Ansible role/task files are prohibited.
- Required secret inputs are sourced externally through environment variables or Ansible Vault:
  - `WAZUH_API_PASSWORD`
  - `CALDERA_API_KEY`
- Missing secret inputs must fail enforcement and compliance validation.

### 6) Logging Requirements
Required log paths on managed Linux nodes:
- `/var/log/auth.log`
- `/var/log/syslog`

Absence of required log paths is non-compliant.

## Compliance Contract
A host is compliant only if all controls in this document pass enforcement and validation. Any violation blocks promotion.
