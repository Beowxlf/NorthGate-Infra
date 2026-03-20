module "domain_controller_windows_vm" {
  source = "../../"

  vm_name   = "test-core-dc01"
  cpu_count = 4
  memory_mb = 8192

  disk = {
    size_gb = 120
    type    = "ssd"
  }

  network_interface = {
    network_id   = "test-core-server-net"
    adapter_type = "vmxnet3"
    ip_address   = "10.40.10.20"
  }

  base_image = {
    image_id      = "windows-server-2022-golden-2026.03.01"
    image_version = "2026.03.01"
    image_source  = "packer/windows-server-2022"
  }

  winrm = {
    transport = "https"
    port      = 5986
    use_tls   = true
  }

  administrator_access = {
    username = "lab-admin"
    method   = "secret_ref"
    secret   = "secret://test-core/domain-controller/lab-admin"
  }

  tags = {
    environment = "test-core"
    service     = "domain-controller"
    os_family   = "windows"
  }
}
