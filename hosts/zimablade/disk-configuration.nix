{ config, lib, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Hardware-specific modules from the hardware-configuration.nix
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # CPU-specific settings
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Disko configuration
  disko.devices = {
    disk.main = {
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
              extraArgs = ["-E" "nodiscard"];
              mountOptions = [ "defaults" "noatime" ];
            };
          };
        };
      };
    };
  };

  # No swap devices
  swapDevices = [ ];
}
