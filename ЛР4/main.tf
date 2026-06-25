terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = { source = "bpg/proxmox", version = "~> 0.70" }
  }
}
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
}

resource "proxmox_virtual_environment_vm" "lab04" {
  for_each = local.vms

  name        = each.value.name
  description = "ЛР4 HA/VIP ${each.key}"
  tags        = ["iac-course", "lab04"]
  node_name   = "pve"
  vm_id       = each.value.id
  started     = true

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.mem
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "vm-storage"
    interface    = "scsi0"
    size         = 20
  }

  initialization {
    datastore_id = "vm-storage"
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }
    user_account {
      username = var.vm_user
      keys     = [local.ssh_key]
    }
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }
}
