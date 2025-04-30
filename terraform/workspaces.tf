locals {
  # Determine active host based on workspace name
  # Default to "generic" if workspace is "default", otherwise use workspace name as host
  active_host = terraform.workspace == "default" ? "generic" : terraform.workspace

  # Get the host config from the hosts_config map
  # If host is specified explicitly, use that instead of the workspace name
  host_to_use = coalesce(var.host, local.active_host)

  # Look up configuration for the selected host
  selected_host_config = var.hosts_config[var.environment][local.host_to_use]

  # Network subnet calculation - use unique subnet based on workspace name
  workspace_subnet = (
    terraform.workspace == "default" ? "100" :
    terraform.workspace == "generic" ? "101" :
    terraform.workspace == "kube" ? "102" :
    "110"
  )

  # Original IP address from config
  original_ip = local.selected_host_config.ip_address

  # Extract the last octet from the original IP
  # For example, from 192.168.123.200, extract 200
  last_octet = tonumber(element(split(".", local.original_ip), 3))

  # Use the original IP address directly from config instead of constructing a new one
  vm_ip_address = local.original_ip
}
