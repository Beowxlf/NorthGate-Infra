terraform {
  required_version = ">= 1.5.0"
}

locals {
  initialization = {
    winrm = {
      transport = lower(var.winrm.transport)
      port      = var.winrm.port
      use_tls   = var.winrm.use_tls
      bootstrap_steps = [
        "Enable-PSRemoting -Force",
        "Set-Item -Path WSMan:\\localhost\\Service\\AllowUnencrypted -Value ${var.winrm.use_tls ? "false" : "true"}",
        "Set-Item -Path WSMan:\\localhost\\Service\\Auth\\Basic -Value true",
        "New-NetFirewallRule -DisplayName 'WinRM Inbound ${var.winrm.port}' -Direction Inbound -Protocol TCP -LocalPort ${var.winrm.port} -Action Allow"
      ]
    }

    administrator_access = {
      username = var.administrator_access.username
      method   = lower(var.administrator_access.method)
      secret   = var.administrator_access.secret
      bootstrap_steps = [
        "net user ${var.administrator_access.username} \"<REDACTED>\"",
        "net localgroup administrators ${var.administrator_access.username} /add"
      ]
    }
  }

  windows_vm_spec = {
    os_family         = "windows"
    name              = var.vm_name
    cpu_count         = var.cpu_count
    memory_mb         = var.memory_mb
    disk              = var.disk
    network_interface = var.network_interface
    base_image        = var.base_image
    initialization    = local.initialization
    tags              = var.tags
  }
}

resource "terraform_data" "windows_vm" {
  input = local.windows_vm_spec
}
