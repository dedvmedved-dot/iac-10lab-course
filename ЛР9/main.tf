# ЛР9: Proxmox VE + Terraform/OpenTofu — массовое создание ВМ
# Эта лабораторная работа учит создавать N ВМ через count/for_each
# Сквозные исправления: clone, ubuntu, vm-storage, без cicustom

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

variable "vm_count" {
  type    = number
  default = 3
}

variable "base_ip" {
  type    = string
  default = "192.168.0.100"
}

variable "prefix" {
  type    = string
  default = "lab09"
}

resource "proxmox_virtual_environment_vm" "mass" {
  count = var.vm_count

  name      = "${var.prefix}-${count.index + 1}"
  node_name = var.proxmox_node_name
  started   = true

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 20
  }

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "${cidrhost("192.168.0.0/24", tonumber(split(".", var.base_ip)[3]) + count.index)}/24"
        gateway = var.gateway
      }
    }
  }
}
