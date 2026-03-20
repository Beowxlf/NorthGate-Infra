#!/usr/bin/env python3
"""Render deterministic Ansible inventory from Terraform outputs."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


def terraform_output_json(terraform_dir: Path) -> dict:
    cmd = ["terraform", "output", "-json", "ansible_inventory_data"]
    proc = subprocess.run(cmd, cwd=terraform_dir, check=True, capture_output=True, text=True)
    return json.loads(proc.stdout)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate ansible inventory YAML/JSON from Terraform outputs.")
    parser.add_argument("--terraform-dir", required=True, help="Path to Terraform environment directory.")
    parser.add_argument("--output", required=True, help="Path to output inventory JSON file.")
    args = parser.parse_args()

    inventory = terraform_output_json(Path(args.terraform_dir))
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(inventory, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
