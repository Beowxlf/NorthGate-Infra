# Networking Infrastructure

## Provisioning Responsibilities
Terraform/OpenTofu manages:
- Segment/subnet creation.
- Route and gateway associations.
- Security group or firewall policy primitives.
- Host interface assignments.

## Module Boundaries
- `network-core` module: shared network primitives.
- `network-segmentation` module: environment segment definitions and policy attachments.
- `network-access` module: ingress and restricted egress rules.

## Naming Convention
- Network object format: `ng-<env>-<segment>-<type>`.
- Examples:
  - `ng-test-core-mgmt-net`
  - `ng-app-hosting-svc-fw`

## Guardrails
- No overlapping CIDR blocks across environments.
- All ingress rules require source and destination scope.
- Catch-all allow rules are disallowed.
