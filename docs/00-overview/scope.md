# Scope

## In Scope

### Infrastructure Layers
1. **Provisioning layer:**
   - Environment network segments, routing, and firewall objects.
   - Virtual machine lifecycle and disk/network attachments.
   - Storage primitives required by core and application services.
2. **Configuration layer:**
   - Base OS hardening and standard package/runtime setup.
   - Service installation and configuration (AD, Wazuh, Prometheus, Grafana, Caldera, supporting services).
   - Host and service policy enforcement (identity, logging, patching, baseline security).
3. **Application layer:**
   - ScrambleIQ infrastructure-facing runtime deployment concerns only.
   - Reverse proxy, app runtime host, persistent database, optional worker service lifecycle.

### Environments
- **`test-core`:** foundational infrastructure and core operational/security services.
- **`workbench`:** operator tooling, control node, security testing tooling.
- **`app-hosting`:** application-facing runtime resources for ScrambleIQ stack.

### Operational System Lifecycle
- Design documentation.
- IaC implementation and validation.
- Controlled deployment and environment promotion.
- Change management, rollback, and failure recovery.

## Out of Scope
- Public cloud-native managed services.
- Non-infrastructure application product requirements.
- Manual one-off host administration not represented as code.

## Scope-to-Phase Mapping
- **Phase 0-1:** Repository conventions, standards, and base IaC scaffolding.
- **Phase 2-5:** Service implementation by functional domain.
- **Phase 6:** CI/policy controls for deterministic delivery.
- **Phase 7:** Disaster/failure scenarios and recoverability validation.
