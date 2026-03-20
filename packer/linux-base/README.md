# Linux Base Image (Packer)

## Scope
This directory contains a deterministic Ubuntu Server LTS base image definition for **all non-Windows hosts** in NorthGate-Infra.

This image intentionally includes only baseline operating system capabilities required for secure remote administration and post-provision configuration management.

## Files
- `template.pkr.hcl` — Packer build template using the QEMU builder.
- `linux-base.auto.pkrvars.hcl` — pinned build inputs and image metadata.
- `build.sh` — deterministic build entrypoint (`init` → `fmt` → `validate` → `build`).
- `http/user-data` and `http/meta-data` — Ubuntu autoinstall input for non-interactive install.
- `scripts/provision.sh` — baseline package/install hardening and cleanup.

## Baseline Packages and Services
The image includes only generic baseline components:
1. OpenSSH Server
2. Python3 (Ansible dependency)
3. `sudo`
4. Basic system utilities (`curl`, `ca-certificates`, `jq`, `vim-tiny`, `net-tools`, `iproute2`)
5. Time sync service (`systemd-timesyncd`) enabled

No application-specific software is installed.

## Deterministic Build Inputs
Determinism is enforced through:
1. Pinned ISO URL and SHA256 checksum in `linux-base.auto.pkrvars.hcl`
2. Explicit package list in autoinstall + provision script
3. Non-interactive autoinstall (`cloud-init` nocloud datasource)
4. Post-build cleanup of transient package metadata
5. Removal of machine-unique identifiers (`machine-id` reset)

## Build Instructions
From repository root:

```bash
cd packer/linux-base
./build.sh
```

Expected artifact:
- `packer/linux-base/output/northgate-ubuntu-24-04-lts-v1/northgate-ubuntu-24-04-lts-v1.qcow2`

## Terraform and Ansible Integration
### Terraform integration
- Terraform consumes this image artifact as the **base compute image** for Linux VM resources.
- Environment-specific Terraform layers must reference this image by explicit version tag (for example `northgate-ubuntu-24-04-lts-v1`) instead of mutable names like `latest`.
- This aligns with the service catalog and environment model by providing a shared, reproducible Linux substrate across `test-core`, `workbench`, and `app-hosting`.

### Ansible integration
- Ansible assumes Python is present on target nodes; this image guarantees `python3` availability at first boot.
- Ansible roles/playbooks then apply environment/service-specific configuration *after* Terraform provisioning.
- This preserves separation of concerns: Packer builds immutable baseline OS images, Terraform provisions infrastructure, and Ansible performs runtime configuration.
