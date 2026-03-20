# domain_controller role

Configures a Windows host as the first Domain Controller for a new Active Directory forest.

## Scope

This role performs the bootstrap path only:

1. Installs AD DS and DNS server roles.
2. Promotes the host to a Domain Controller.
3. Creates a new forest using the configured domain name.
4. Reboots and verifies AD DS/DNS services are present.

The role intentionally does **not** assume a pre-existing domain.

## Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `domain_controller_domain_name` | No | `northgateops` | AD forest root domain for bootstrap. |
| `domain_controller_netbios_name` | No | Derived from domain | NetBIOS name passed to ADDS forest creation. |
| `domain_controller_safe_mode_password` | Yes | `""` | DSRM password. Must be supplied securely (Vault/external secret manager). |
| `domain_controller_install_dns` | No | `true` | Installs and configures integrated DNS during promotion. |
| `domain_controller_windows_features` | No | `[AD-Domain-Services, DNS]` | Windows features required for bootstrap. |

## Secret Handling

- Store `domain_controller_safe_mode_password` in an encrypted variable file (Ansible Vault).
- Promotion task is `no_log: true` to avoid leaking credentials in controller output.

Example with vault-encrypted vars file:

```yaml
# group_vars/directory_services/vault.yml (encrypted)
domain_controller_safe_mode_password: "REDACTED"
```

## Idempotency and reruns

- Windows feature installation is idempotent (`state: present`).
- Role checks if NTDS service already exists. If so, forest creation is skipped.
- Reboots occur only when required by feature install or when promotion executes.
- Post-checks validate `NTDS` and `DNS` services to ensure role convergence.
