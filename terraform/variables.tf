variable "environment" {
  description = "Deployment environment (local)"
  type        = string
  default     = "local"
}

variable "libvirt_network_name" {
  description = "Name of the libvirt network"
  type        = string
  default     = "vm_network"
}

variable "libvirt_pool_name" {
  description = "Name of the libvirt storage pool"
  type        = string
  default     = "vm_pool"
}

# ----------------------------------------------------------------------

# Variable to define all host configurations across environments
variable "hosts_config" {
  description = "Configuration data for all hosts, structured by environment."
  type = map(map(object({
    ip_address         = string
    build_image_source = string
    cpu_cores          = number
    memory_mb          = number
    disk_size_gb       = number
    username           = string
    flake_attribute    = string
  })))

  default = {
    "local" = {
      "generic" = {
        ip_address         = "192.168.101.200"
        build_image_source = "../generic.raw"
        cpu_cores          = 6
        memory_mb          = 8192
        disk_size_gb       = 40
        username           = "admin"
        flake_attribute    = "genericImage"
      },
      "kube" = {
        ip_address         = "192.168.102.100"
        build_image_source = "../kube.raw"
        cpu_cores          = 6
        memory_mb          = 8192
        disk_size_gb       = 40
        username           = "admin"
        flake_attribute    = "kubernetesImage"
      },
      "zimablade" = {
        ip_address         = "192.168.100.222"
        build_image_source = "../zimablade.raw"
        cpu_cores          = 2
        memory_mb          = 8192
        disk_size_gb       = 32
        username           = "admin"
        flake_attribute    = "zimablade"
      }
    },
  }
}

# For backward compatibility
variable "host" {
  description = "The name of a single host to deploy. This is optional when using workspaces."
  type        = string
  default     = ""
}
