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
  ssh_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  vms =     {
    "iscsi1" = { id = 1130, ip = "192.168.0.230/24", cores = 2, mem = 2048, disk = 20 }
    "gfs-node1" = { id = 1131, ip = "192.168.0.231/24", cores = 2, mem = 2048, disk = 20 }
    "gfs-node2" = { id = 1132, ip = "192.168.0.232/24", cores = 2, mem = 2048, disk = 20 }
    "gfs-node3" = { id = 1133, ip = "192.168.0.233/24", cores = 2, mem = 2048, disk = 20 }
    }
}

resource "proxmox_virtual_environment_vm" "Приложение_Г" {
  for_each = local.vms

  name      = each.key
  node_name = var.proxmox_node_name
  vm_id     = each.value.id
  started   = true

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.mem
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = each.value.disk
  }

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_Приложение_Г.id
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_Приложение_Г" {
  node_name    = var.proxmox_node_name
  datastore_id = "local"
  content_type = "snippets"

  source_raw {
    data = <<-EOF
      #cloud-config
      ssh_pwauth: false
      users:
        - name: ${var.vm_user}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${local.ssh_key}
          lock_passwd: true
      runcmd:
        - hostnamectl set-hostname each.key
    EOF
    file_name = "cloud-init-Приложение_Г.yml"
  }
}
