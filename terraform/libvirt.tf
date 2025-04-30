resource "libvirt_pool" "vm_pool" {
  count = var.environment == "local" ? 1 : 0
  name  = "${var.libvirt_pool_name}_${terraform.workspace}"
  type  = "dir"
  path  = "/var/lib/libvirt/images/nixos-server-${terraform.workspace}"
}

resource "libvirt_volume" "build_img" {
  for_each = var.environment == "local" ? { "${local.host_to_use}" = var.hosts_config[var.environment][local.host_to_use] } : {}

  name   = "${var.environment}-${each.key}-base"
  pool   = libvirt_pool.vm_pool[0].name
  source = each.value.build_image_source
  format = endswith(each.value.build_image_source, ".raw") ? "raw" : "qcow2"

  depends_on = [libvirt_pool.vm_pool]
}

resource "libvirt_network" "vm_network" {
  count  = var.environment == "local" ? 1 : 0
  name   = "${var.libvirt_network_name}_${terraform.workspace}"
  mode   = "nat"
  domain = "${terraform.workspace}.vm.local"
  # Get the network address from the IP (first 3 octets + 0)
  addresses = ["${join(".", concat(slice(split(".", local.original_ip), 0, 3), ["0"]))}/24"]
  autostart = true
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}

resource "libvirt_volume" "vm_volume" {
  for_each = var.environment == "local" ? { "${local.host_to_use}" = var.hosts_config[var.environment][local.host_to_use] } : {}

  name           = "${var.environment}-${each.key}-disk${endswith(each.value.build_image_source, ".raw") ? ".raw" : ".qcow2"}"
  pool           = libvirt_pool.vm_pool[0].name
  base_volume_id = libvirt_volume.build_img[each.key].id
  size           = each.value.disk_size_gb * 1024 * 1024 * 1024
}

variable "ovmf_code_path" {
  description = "Path to the OVMF code firmware file on the KVM host"
  type        = string
  # On NixOS, using system-level symlink that persists across updates
  # default = "/run/current-system/sw/share/qemu/edk2-x86_64-secure-code.fd"
  default = "/run/libvirt/nix-ovmf/OVMF_CODE.fd"

  # On Arch Linux
  # default     = "/usr/share/OVMF/x64/OVMF_CODE.4m.fd"
}

variable "nvram_store_dir" {
  description = "Directory for storing instance NVRAM files on the KVM host"
  type        = string
  default     = "/var/lib/libvirt/qemu/nvram"
}

variable "ovmf_vars_template_path" {
  description = "Optional path to an OVMF variables template file on the KVM host"
  type        = string
  # On NixOS, using system-level symlink that persists across updates
  # default = "/run/current-system/sw/share/qemu/edk2-i386-vars.fd"
  default = "/run/libvirt/nix-ovmf/OVMF_VARS.fd"

  # On Arch Linux
  # default     = "/usr/share/OVMF/x64/OVMF_VARS.4m.fd"
}

resource "libvirt_domain" "vm" {
  for_each = var.environment == "local" ? { "${local.host_to_use}" = var.hosts_config[var.environment][local.host_to_use] } : {}

  name   = "${var.environment}-${each.key}"
  memory = each.value.memory_mb
  vcpu   = each.value.cpu_cores

  machine = "q35"

  # Usually the UEFI firmware needs these configs with the corrects paths for the OVMF_CODE and OVMF_VARS in order to work, but on nixos it just doesn't so you need to do the one below this and i have no idea why
  # firmware = var.ovmf_code_path
  # nvram {
  #   file     = "${var.nvram_store_dir}/${var.environment}-${each.key}_VARS.fd"
  #   template = var.ovmf_vars_template_path
  # }

  # This is LITERALLY manually writing the xml config for the libvirt vm
  xml {
    xslt = <<-XSLT
    <?xml version="1.0" ?>
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output omit-xml-declaration="yes" indent="yes"/>
      <xsl:template match="@*|node()">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:template>
      <xsl:template match="/domain/features">
        <features>
          <xsl:apply-templates select="@*|node()"/>
          <smm state="on"/>
        </features>
      </xsl:template>
      <xsl:template match="/domain/os">
        <os>
          <type arch="x86_64" machine="q35">hvm</type>
          <loader readonly="yes" secure="yes" type="pflash" format="raw">${var.ovmf_code_path}</loader>
          <nvram templateFormat="raw" template="${var.ovmf_vars_template_path}">/var/lib/libvirt/qemu/nvram/${var.environment}-${each.key}_VARS.fd</nvram>
          <boot dev="hd"/>
        </os>
      </xsl:template>
    </xsl:stylesheet>
    XSLT
  }

  lifecycle {
    ignore_changes = [
      nvram,
    ]
  }
  # Use autostart for the VM
  autostart = true

  network_interface {
    network_name   = "${var.libvirt_network_name}_${terraform.workspace}"
    wait_for_lease = false
    addresses      = [local.vm_ip_address]
  }

  # Disk configuration
  disk {
    volume_id = libvirt_volume.vm_volume[each.key].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
