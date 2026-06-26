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

  vms = {
    "pg-01"    = { id = 401, ip = "192.168.0.151/24", cores = 2, mem = 4096 }
    "pg-02"    = { id = 402, ip = "192.168.0.152/24", cores = 2, mem = 4096 }
    "pg-03"    = { id = 403, ip = "192.168.0.153/24", cores = 2, mem = 4096 }
    "etcd-01"  = { id = 411, ip = "192.168.0.161/24", cores = 2, mem = 2048 }
    "etcd-02"  = { id = 412, ip = "192.168.0.162/24", cores = 2, mem = 2048 }
    "etcd-03"  = { id = 413, ip = "192.168.0.163/24", cores = 2, mem = 2048 }
    "pg-lb-01" = { id = 421, ip = "192.168.0.171/24", cores = 2, mem = 2048 }
  }
}

resource "proxmox_virtual_environment_vm" "lab05" {
  for_each = local.vms

  name    = each.key
  node_name = var.proxmox_node_name
  vm_id   = each.value.id
  started = true

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
    file_id      = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
    interface    = "scsi0"
    size         = 20
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_snippet.id
  }

  clone {
    vm_id = var.template_vm_id
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_snippet" {
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
        - hostnamectl set-hostname ${each.key}
    EOF
    file_name = "cloud-init-lab05.yml"
  }
}
