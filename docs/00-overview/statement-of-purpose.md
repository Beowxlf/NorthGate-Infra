# Statement of Purpose

## Mission
NorthGate-Infra is the authoritative Infrastructure-as-Code repository for the NorthGate local lab platform. It defines how infrastructure is provisioned, configured, and operated using Terraform/OpenTofu, Ansible, and Packer.

## Repository Contract
This repository must be sufficient to:
1. Rebuild each defined environment from scratch.
2. Explain why infrastructure is designed the way it is.
3. Enable safe changes through Git-based review and CI validation.
4. Support AI-assisted editing without introducing ambiguity.

## Supported Toolchain
- **Provisioning layer:** Terraform/OpenTofu.
- **Configuration layer:** Ansible.
- **Image layer:** Packer.
- **Automation and checks:** Scripts and GitHub Actions workflows.

## Non-Goals
- This repository is not an application source repository.
- This repository does not store production secrets in plaintext.
- This repository does not define cloud-specific managed services by default.

## Source-of-Truth Rules
- Architecture intent is documented in `docs/` before major implementation changes.
- Environment differences are captured under `docs/04-environments/` and mirrored in code.
- Shared modules and roles are reusable; environment directories compose them.
