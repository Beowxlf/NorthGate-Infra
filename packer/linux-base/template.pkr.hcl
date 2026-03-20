packer {
  required_version = ">= 1.10.0"

  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.1"
    }
  }
}

variable "image_name" {
  type        = string
  description = "Output image name prefix."
}

variable "ubuntu_iso_url" {
  type        = string
  description = "Pinned Ubuntu Server ISO URL."
}

variable "ubuntu_iso_checksum" {
  type        = string
  description = "Pinned Ubuntu Server ISO checksum in sha256:<value> format."
}

variable "output_directory" {
  type        = string
  description = "Directory where the built qcow2 artifact is written."
  default     = "output"
}

variable "disk_size_mb" {
  type        = number
  description = "Disk size in MB for the base image."
  default     = 20480
}

variable "memory_mb" {
  type        = number
  description = "Memory in MB for QEMU during image build."
  default     = 2048
}

variable "cpus" {
  type        = number
  description = "Virtual CPUs for QEMU during image build."
  default     = 2
}

variable "ssh_username" {
  type        = string
  description = "Temporary provisioning user created during autoinstall."
  default     = "packer"
}

variable "ssh_password" {
  type        = string
  sensitive   = true
  description = "Temporary provisioning user password used during build only."
}

source "qemu" "ubuntu_lts" {
  vm_name           = "${var.image_name}.qcow2"
  output_directory  = "${var.output_directory}/${var.image_name}"
  format            = "qcow2"
  accelerator       = "kvm"
  disk_interface    = "virtio"
  net_device        = "virtio-net"
  disk_size         = var.disk_size_mb
  memory            = var.memory_mb
  cpus              = var.cpus
  headless          = true
  shutdown_command  = "echo '${var.ssh_password}' | sudo -S shutdown -P now"

  iso_url           = var.ubuntu_iso_url
  iso_checksum      = var.ubuntu_iso_checksum

  http_directory    = "${path.root}/http"

  boot_wait         = "5s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  communicator      = "ssh"
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_timeout       = "30m"
}

build {
  name    = "linux-base"
  sources = ["source.qemu.ubuntu_lts"]

  provisioner "shell" {
    script = "${path.root}/scripts/provision.sh"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
  }
}
