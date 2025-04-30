{ lib, config, ... }: {

  # Enable automatic partition resizing for VM environments
  # This will grow the root partition to fill available space
  boot.growPartition = true;
  
  # File system-specific auto-resize configuration
  fileSystems."/".autoResize = true;
  fileSystems."/home".autoResize = true;
  fileSystems."/nix".autoResize = true;
  fileSystems."/var".autoResize = true;

  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot"; # Explicitly name the boot partition
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "defaults" "noatime" ];
            };
          };

          root = {
            name = "nixos"; # This creates disk-main-nixos partition label
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f" # Force formatting
                "-L"
                "nixos_vm_root"
              ]; # Set filesystem label
              subvolumes = {
                "/@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" "space_cache=v2" ];
                };
                "/@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" "space_cache=v2" ];
                };
                "/@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" "space_cache=v2" ];
                };
                "/@var" = {
                  mountpoint = "/var";
                  mountOptions = [ "compress=zstd" "noatime" "space_cache=v2" ];
                };
              };
            };
          };
        };
      };
    };
  };

}
