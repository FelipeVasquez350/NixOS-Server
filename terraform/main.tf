terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Create the build directory if it doesn't exist

# Generate the appropriate VM image based on the host configuration
# resource "null_resource" "generate_image" {
#   for_each = var.environment == "local" ? { "${local.host_to_use}" = var.hosts_config[var.environment][local.host_to_use] } : {}

#   triggers = {
#     host_name  = local.host_to_use
#     flake_attr = each.value.flake_attribute
#     # Add content hash trigger to ensure rebuilding when config changes
#     config_hash = sha256(jsonencode(each.value))
#   }

#   provisioner "local-exec" {
#     command     = <<-EOT
#       echo "Generating image for ${each.key} using flake attribute ${each.value.flake_attribute}"

#       # Handle different image types
#       if [[ "${each.value.flake_attribute}" == *"diskoImageScript" ]]; then
#         echo "Generating disko raw image..."
#         # Build the disko image script
#         nix build .#${each.value.flake_attribute} --no-link
#         # Execute the script with sudo to generate the raw image
#         # NOTE: This will create nixos-generic-vm.raw in the current directory
#         sudo $(nix path-info .#${each.value.flake_attribute}) --build-memory 4096
#       else
#         echo "Generating standard qcow2 image..."
#         rm -f ./${each.key}.qcow2
#         nix build .#${each.value.flake_attribute} --no-link
#         cp $(nix path-info .#${each.value.flake_attribute})/nixos.qcow2 ./${each.key}.qcow2
#       fi
#     EOT
#     working_dir = ".." # Execute from terraform directory from the root dir
#   }

# }
