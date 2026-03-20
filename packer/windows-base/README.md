# windows-base

Deterministic Windows Server 2022 base image pipeline for Domain Controller provisioning.

## Build

```bash
packer init template.pkr.hcl
packer build -var-file=windows-base.auto.pkrvars.hcl template.pkr.hcl
```

## Output Artifact

`output/windows-server-2022-base/*.qcow2` is the immutable base image consumed by `terraform/modules/windows-vm`.
