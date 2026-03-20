# wazuh role

Deploys Wazuh SIEM central services on a Linux host using the official Wazuh installation assistant.

## What this role installs

- Wazuh manager
- Wazuh indexer
- Wazuh dashboard

## Deployment flow

1. Preflight checks validate supported OS family and install prerequisites (`curl`, `tar`).
2. Role renders a deterministic `config.yml` template for node identity and addressing.
3. Role runs the Wazuh installer in all-in-one mode (`-a`) for clean install.
4. Optional forced redeploy uninstalls and reinstalls stack (`-u` then `-a --overwrite`).
5. Post-install manager tuning is rendered from template.
6. Validation checks assert services are running and required ports are listening.

## Key variables

| Variable | Purpose | Default |
|---|---|---|
| `wazuh_version` | Wazuh release used by installer | `4.14.4` |
| `wazuh_force_redeploy` | Uninstall/reinstall existing stack | `false` |
| `wazuh_redeploy_on_config_change` | Reinstall when `config.yml` changes | `false` |
| `wazuh_node_name` | Node name used in installer config | `wazuh-single-node` |
| `wazuh_node_ip` | Node IP used for manager/indexer/dashboard | `{{ ansible_default_ipv4.address }}` |
| `wazuh_services` | Services validated by role | manager/indexer/dashboard |

## Example usage

```yaml
- name: Deploy Wazuh stack
  hosts: wazuh_manager
  become: true
  roles:
    - role: wazuh
```

## Notes

- Role is designed for deterministic, non-interactive deployment.
- No manual pre-install tasks are required.
- Redeploy behavior is explicit and controlled by role variables.
