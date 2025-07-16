{ lib, ... }: {

  # Enable automatic partition resizing for VM environments
  # This will grow the root partition to fill available space
  boot.growPartition = true;

  # File system-specific auto-resize configuration
  fileSystems."/".autoResize = true;

  disko.devices = {
    disk.mmcblk0 = {
      device = lib.mkDefault "/dev/mmcblk0";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "256M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "defaults" "noatime" "fmask=0022" "dmask=0022" ];
            };
          };

          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [ "-E" "nodiscard" ];
              mountOptions = [ "defaults" "noatime" ];
            };
          };
        };
      };
    };
  };
}
