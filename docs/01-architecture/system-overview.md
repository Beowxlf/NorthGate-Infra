# System Overview

## Architectural Layers
NorthGate infrastructure is implemented in three layers:

1. **Provisioning layer (Terraform/OpenTofu):** creates networks, storage, and VM resources.
2. **Configuration layer (Ansible):** configures operating systems, baseline services, and security controls.
3. **Application layer:** deploys and configures application services after host baselines pass validation.

## Control Flow
1. Git change is proposed.
2. CI validates Terraform/OpenTofu, Ansible, and documentation structure.
3. Terraform/OpenTofu applies infrastructure changes to target environment.
4. Ansible applies role-based configuration.
5. Application deployment jobs run.
6. Post-deployment validation confirms service and host health.

## Core Components
- **Hypervisor/virtualization substrate:** local lab compute fabric.
- **VM workloads:** control, utility, and application-hosting roles.
- **Network segments:** management, service, and optional ingress zones.
- **State and artifacts:** Terraform state backend and image artifacts.

## Design Principles
- Deterministic naming and directory conventions.
- Reuse via modules (Terraform/OpenTofu) and roles (Ansible).
- Environment composition from shared building blocks.
- Secure defaults with explicit exceptions.
