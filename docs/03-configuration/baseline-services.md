# Baseline Services

## Mandatory Baseline on All Managed Nodes
- Time synchronization client.
- Centralized logging/telemetry agent (Wazuh agent where applicable).
- OS patch/update policy enforcement.
- Administrative access policy and audit logging.
- Host firewall baseline.

## Foundational Service Ordering
1. Network and resolver settings.
2. Time synchronization.
3. Identity trust/join behavior (where required).
4. Security telemetry agent installation.
5. Service-specific runtime dependencies.

## Environment-Specific Baseline Notes
- `test-core`: includes identity and observability control-plane services.
- `workbench`: includes operator tooling and automation runtime prerequisites.
- `app-hosting`: includes app runtime prerequisites and database client/tooling controls.
