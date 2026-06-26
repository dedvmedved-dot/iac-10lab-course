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
  vms =     {
    "consul1" = { id = 608, ip = "192.168.0.181/24", cores = 2, mem = 2048, disk = 20 }
    "consul2" = { id = 609, ip = "192.168.0.182/24", cores = 2, mem = 2048, disk = 20 }
    "consul3" = { id = 610, ip = "192.168.0.183/24", cores = 2, mem = 2048, disk = 20 }
    "web1" = { id = 611, ip = "192.168.0.184/24", cores = 1, mem = 1024, disk = 20 }
    "web2" = { id = 612, ip = "192.168.0.185/24", cores = 1, mem = 1024, disk = 20 }
    }
}

resource "proxmox_virtual_environment_vm" "ЛР8" {
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
    user_data_file_id = "snippets:cloud-init-lr8.yml"
  }
}
