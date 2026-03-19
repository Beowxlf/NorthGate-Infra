# Environment: test-core

## Purpose
`test-core` is the first validation target for infrastructure and configuration changes.

## Characteristics
- Disposable environment with minimal footprint.
- Fast provision and teardown cycle.
- Representative network segmentation with reduced capacity.

## Expected VM Roles
- `ctl`: 1 node
- `cfg`: 1 node (or combined with `ctl` for minimal footprint)
- `app`: 1-2 nodes for smoke validation
- `obs`: optional lightweight monitoring node

## Change Policy
- Direct commits to environment definitions are allowed through standard PR flow.
- Frequent rebuilds are expected; persistent data is not required.

## Validation Gates
- Terraform/OpenTofu plan/apply succeeds.
- Ansible baseline playbook succeeds with no unhandled changes on second run.
- Smoke checks pass for core services.
