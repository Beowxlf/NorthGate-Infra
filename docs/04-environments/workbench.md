# workbench Environment

## Purpose
`workbench` is the operator and security-testing environment that hosts the automation control plane and adversary simulation tooling.

## Mandatory Services
- Jump host.
- Control node for Terraform/OpenTofu and Ansible execution.
- Caldera and approved attack simulation host.

## Responsibilities
- Provide controlled administrative entry path.
- Execute provisioning/configuration workflows against all environments.
- Run security validation scenarios in bounded scope.

## Boundary Rules
- Must not host production application runtime workloads.
- Maintains privileged connectivity only as required for managed operations.

## Phase Alignment
- Core delivery in phase 2 (control/jump).
- Security expansion in phase 4 (Caldera + simulation tooling).
