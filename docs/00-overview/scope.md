# Scope

## In Scope
- Virtual machine, network, and storage infrastructure for a local lab environment.
- Reusable Terraform/OpenTofu modules and environment root configurations.
- Reusable Ansible roles, inventories, and playbooks.
- Packer build definitions for baseline images.
- Operational procedures for deployment, change control, and recovery.

## Out of Scope
- Application feature development and application business logic.
- Cloud-provider-specific managed service design unless explicitly added later.
- Secret values stored directly in Git.

## Environment Scope
This repository defines three environments:
1. **test-core**: integration and CI-safe infrastructure validation.
2. **workbench**: engineer sandbox for iterative infrastructure and configuration testing.
3. **app-hosting**: stable environment for hosting long-running lab applications.

## Ownership Scope
- Infrastructure engineers own Terraform/OpenTofu, Packer templates, and system topology decisions.
- Platform engineers own Ansible role baselines and service configuration standards.
- All contributors must follow naming, security, and workflow standards defined in `docs/`.
