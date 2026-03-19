# Environment: workbench

## Purpose
`workbench` is a collaborative sandbox for infrastructure engineers to test candidate changes before stable promotion.

## Characteristics
- Semi-persistent environment.
- Supports temporary feature branches and integration experiments.
- Higher capacity than `test-core`.

## Expected VM Roles
- `ctl`: 1-2 nodes
- `cfg`: 1 node
- `app`: 2+ nodes for integration scenarios
- `obs`: 1 node

## Change Policy
- Changes must originate in Git branch and pass CI before apply.
- Temporary experiments must be cleaned up or promoted.

## Validation Gates
- Baseline service health checks.
- Network policy validation across mgmt/svc/ingress segments.
- Integration-level application deployment checks.
