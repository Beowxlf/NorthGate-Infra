# Failure and Recovery

## Recovery Objectives
- Restore minimum viable platform in dependency order.
- Preserve deterministic behavior during rebuild and restore.
- Validate recoverability as a recurring operational exercise (phase 7).

## Dependency-Based Recovery Order
1. **Network and foundational provisioning primitives**
2. **Identity and naming (Domain Controller, DNS, time)**
3. **Control-plane access (jump host, control node)**
4. **Security/observability (Wazuh, Prometheus, Grafana)**
5. **Security testing tooling (Caldera stack)**
6. **Application hosting (proxy, app, DB, workers)**

## Failure Scenarios to Validate
- Complete environment rebuild from zero.
- Loss of control node and restoration of automation capability.
- Identity service outage with dependent service restoration.
- Database failure with application recovery.
- Telemetry stack outage and monitoring restoration.

## Recovery Procedure Rules
- Execute infrastructure recreation through Terraform/OpenTofu first.
- Reapply Ansible roles in documented dependency order.
- Restore data from approved backups before opening dependent services.
- Record incident timeline, root cause, and permanent corrective IaC updates.
