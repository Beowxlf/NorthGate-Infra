# Network Design

## Network Objectives
- Isolate environment concerns while preserving controlled service dependencies.
- Provide deterministic addressing and naming for automation.
- Enforce policy boundaries between management, platform, and application traffic.

## Environment Network Boundaries

### `test-core`
- Hosts identity, monitoring, and foundational shared services.
- Receives controlled administration from `workbench` only.
- Exposes only required ports to dependent environments.

### `workbench`
- Hosts operator/control-plane resources (jump host, control node, security tooling).
- Has administrative access paths into `test-core` and `app-hosting` based on least privilege.

### `app-hosting`
- Hosts application runtime and data services.
- Receives operator access from `workbench` and service dependencies from `test-core`.

## Segmentation Model
- **Management segment:** administrative and automation control traffic.
- **Service segment:** east-west service communications.
- **Ingress segment (optional):** controlled inbound path for application endpoints.

## Naming Conventions
- Network objects use: `ng-<env>-<segment>-<purpose>-<index>`.
- Examples:
  - `ng-test-core-net-mgmt-01`
  - `ng-workbench-net-svc-01`
  - `ng-app-hosting-net-ingress-01`

## Dependency Rules
- DNS/time services must be reachable from all managed nodes.
- Identity-dependent services (e.g., domain-integrated hosts) require domain and DNS before service activation.
- Monitoring agents require outbound path to Wazuh and Prometheus endpoints.
