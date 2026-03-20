packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.1.0"
    }
  }
}

variable "windows_iso_path" {
  type        = string
  description = "Path to Windows Server ISO used for deterministic build."
}

variable "windows_iso_checksum" {
  type        = string
  description = "SHA256 checksum for the Windows Server ISO."
}

variable "vm_name" {
  type    = string
  default = "windows-server-2022-base"
}

variable "output_directory" {
  type    = string
  default = "output/windows-server-2022-base"
}

source "qemu" "windows_server_2022" {
  accelerator      = "kvm"
  communicator     = "winrm"
  cpus             = 4
  memory           = 8192
  disk_interface   = "virtio"
  disk_size        = "61440"
  format           = "qcow2"
  headless         = true
  iso_url          = var.windows_iso_path
  iso_checksum     = var.windows_iso_checksum
  output_directory = var.output_directory
  qemu_binary      = "qemu-system-x86_64"
  shutdown_command = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""

  http_directory = "${path.root}/http"

  floppy_files = [
    "${path.root}/scripts/autounattend.xml",
    "${path.root}/scripts/setup-winrm.ps1"
  ]

  winrm_username = "Administrator"
  winrm_password = "PackerBuildPassword!"
  winrm_timeout  = "2h"
}

build {
  name = "windows-server-2022-base"
  sources = ["source.qemu.windows_server_2022"]

  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/install-cloudbase-init.ps1",
      "${path.root}/scripts/sysprep.ps1"
    ]
  }
}
