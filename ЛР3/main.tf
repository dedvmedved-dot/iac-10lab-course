terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
}

locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  vms = {
    web = {
      name   = "web-01"
      vm_id  = 201
      ip     = "192.168.0.101/24"
      cores  = 2
      memory = 2048
      role   = "web"
    }

    app = {
      name   = "app-01"
      vm_id  = 211
      ip     = "192.168.0.111/24"
      cores  = 2
      memory = 2048
      role   = "app"
    }

    db = {
      name   = "db-01"
      vm_id  = 221
      ip     = "192.168.0.121/24"
      cores  = 2
      memory = 3072
      role   = "db"
    }
  }
}

resource "proxmox_virtual_environment_vm" "lab03" {
  for_each = local.vms

  name        = each.value.name
  description = "Lab 03 ${each.value.role} VM"
  tags        = ["iac-course", "lab03", each.value.role]

  node_name = var.proxmox_node_name
  vm_id     = each.value.vm_id

  started = true

  # КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: clone из шаблона
  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
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
      keys     = [local.ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }
}
