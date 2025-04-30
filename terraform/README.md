# NixOS-Server Terraform Configuration

This directory contains Terraform configurations for deploying NixOS servers in different environments.

## Simplified Workspace-Based Deployment

This configuration uses Terraform workspaces to maintain separate states for each host without requiring separate configuration files. Each host's configuration is defined in the `variables.tf` file.

## File Structure

- `main.tf` - Main Terraform configuration
- `variables.tf` - Variable definitions including all host configurations
- `workspaces.tf` - Logic for selecting hosts based on workspace names
- `libvirt.tf` - LibVirt provider configuration for VM management
- `outputs.tf` - Output definitions

## Host Configuration

All host-specific configurations are defined in the `hosts_config` variable, including:
- CPU cores
- Memory allocation
- Disk size
- Username for cloud-init
- IP address

## Using Terraform Workspaces

Terraform workspaces provide separate state files for each host without duplicating code. The workspace name is used to determine which host configuration to use.

### Basic Commands

```bash
# List workspaces
terraform workspace list

# Create a workspace for a specific host
terraform workspace new generic
terraform workspace new kube

# Switch to a specific host workspace
terraform workspace select generic
terraform workspace select kube

# Apply configuration for current workspace (no tfvars needed)
terraform apply
```

## How It Works

- When you select a workspace named "generic", it will use the configurations for the generic host
- When you select a workspace named "kube", it will use the configurations for the kube host
- Each workspace has its own state file, so hosts don't interfere with each other
- No tfvars files are needed since all configurations are in variables.tf

## Adding a New Host Type

1. Add a new entry to the `hosts_config` variable in `variables.tf`:

```terraform
"new-host" = {
  ip_address         = "192.168.123.xxx"
  build_image_source = "../build/new-host.qcow2"
  cpu_cores          = 2
  memory_mb          = 2048
  disk_size_gb       = 20
  username           = "zima"
}
```

2. Create a new workspace and apply:

```bash
terraform workspace new new-host
terraform apply
```
