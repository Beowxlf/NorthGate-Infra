# app-hosting Environment

## Purpose
`app-hosting` runs application-facing infrastructure components for the ScrambleIQ stack.

## Mandatory Services
- Reverse proxy.
- ScrambleIQ application host.
- Database service.
- Optional worker service (enabled by workload requirement).

## Responsibilities
- Host and expose application runtime through controlled ingress.
- Persist application data with backup-integrated storage.
- Consume shared identity, DNS, and observability services from upstream environments.

## Boundary Rules
- Must not become the source for global identity or monitoring control services.
- Application release concerns are handled after infrastructure and baseline configuration complete.

## Phase Alignment
- Delivered in phase 5 after foundational and security phases are operational.
- Subject to CI/policy and recovery validation in phases 6-7.
