locals {
  # For local environment, extract the VM IP address
  vm_ip = var.environment == "local" ? local.vm_ip_address : null
}

output "vm_information" {
  description = "Information about the created VM"
  value = var.environment == "local" ? {
    name         = "${var.environment}-${local.host_to_use}"
    ip_address   = local.vm_ip_address
    ssh_command  = "ssh ${local.selected_host_config.username}@${local.vm_ip}"
    hostname     = "${var.environment}-${local.host_to_use}.${terraform.workspace}.vm.local"
    environment  = var.environment
    host_type    = local.host_to_use
    flake_attr   = local.selected_host_config.flake_attribute
    username     = local.selected_host_config.username
    cpu_cores    = local.selected_host_config.cpu_cores
    memory_mb    = local.selected_host_config.memory_mb
    disk_size_gb = local.selected_host_config.disk_size_gb
    workspace    = terraform.workspace
  } : null
}

output "instructions" {
  description = "Instructions for connecting to the VM"
  value = var.environment == "local" ? (<<-EOT
    VM "${var.environment}-${local.host_to_use}" has been created!

    Connection details:
    - IP Address: ${local.vm_ip}
    - Hostname: ${var.environment}-${local.host_to_use}.${terraform.workspace}.vm.local
    - SSH Command: ssh ${local.selected_host_config.username}@${local.vm_ip}

    The VM has been configured according to the ${local.host_to_use} template.
    CPU: ${local.selected_host_config.cpu_cores} cores
    Memory: ${local.selected_host_config.memory_mb} MB
    Disk: ${local.selected_host_config.disk_size_gb} GB
    User: ${local.selected_host_config.username}
    Flake Attribute: ${local.selected_host_config.flake_attribute}

    Workspace: ${terraform.workspace}
  EOT
  ) : null
}
