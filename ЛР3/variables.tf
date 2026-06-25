variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "vm_user" {
  description = "Default VM user"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "gateway" {
  description = "Default gateway"
  type        = string
  default     = "192.168.0.1"
}
