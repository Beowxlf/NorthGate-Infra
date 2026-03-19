# packer/

## Purpose
`packer/` contains image build definitions used to produce reproducible base VM images for the local lab.

## What belongs here
- Packer templates and variable files.
- Provisioner scripts used during image creation.
- Image build metadata and versioning notes.

## What does NOT belong here
- Runtime configuration that should be managed by Ansible after provisioning.
- Environment-specific infrastructure state.
- Application deployment artifacts.
