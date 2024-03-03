resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.node_name
  description = var.description
  tags        = var.tags

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = var.qemu_agent
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
    file_id = coalesce(var.template_file_id, proxmox_virtual_environment_file.latest_ubuntu_22_jammy_qcow2_img.id)
    interface    = var.disk_interface
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }
    user_account {
      keys = [
        trimspace(file(var.ssh_public_key_file))
      ]
      password = var.user_password
      username = var.user_username
    }
    user_data_file_id = var.cloud_config_id != null ? var.cloud_config_id : null
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}
}

# Used by default if not defined
resource "proxmox_virtual_environment_download_file" "latest_ubuntu_22_jammy_qcow2_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}