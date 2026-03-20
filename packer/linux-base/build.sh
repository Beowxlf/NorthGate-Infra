#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}"

packer init template.pkr.hcl
packer fmt -check template.pkr.hcl linux-base.auto.pkrvars.hcl
packer validate -var-file=linux-base.auto.pkrvars.hcl template.pkr.hcl
packer build -force -var-file=linux-base.auto.pkrvars.hcl template.pkr.hcl
