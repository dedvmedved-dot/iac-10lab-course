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
    "log-client01" = { id = 406, ip = "192.168.0.106/24", cores = 2, mem = 2048, disk = 20 }
    "kafka01" = { id = 416, ip = "192.168.0.160/24", cores = 2, mem = 4096, disk = 30 }
    "logstash01" = { id = 417, ip = "192.168.0.161/24", cores = 2, mem = 4096, disk = 20 }
    "search01" = { id = 418, ip = "192.168.0.162/24", cores = 2, mem = 4096, disk = 40 }
    "dashboard01" = { id = 419, ip = "192.168.0.163/24", cores = 2, mem = 4096, disk = 20 }
    }
}

resource "proxmox_virtual_environment_vm" "ЛР6" {
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_ЛР6.id
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_ЛР6" {
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
    file_name = "cloud-init-ЛР6.yml"
  }
}
