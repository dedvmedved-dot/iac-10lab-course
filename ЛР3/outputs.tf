output "vm_names" {
  value = {
    for key, vm in proxmox_virtual_environment_vm.lab03 :
    key => vm.name
  }
}

output "ssh_commands" {
  value = {
    web = "ssh ubuntu@192.168.0.101"
    app = "ssh ubuntu@192.168.0.111"
    db  = "ssh ubuntu@192.168.0.121"
  }
}
