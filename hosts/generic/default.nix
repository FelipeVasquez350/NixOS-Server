# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, ... }:

{
  # Bootloader configuration
  boot = {
    # UEFI bootloader configuration
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # Limit the number of generations
        # Make /boot more secure
        editor = false; # Disable boot entry editing
      };
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "virtio_pci" # VM PCI bus support
        "virtio_blk" # VM disk support
        "virtio_scsi" # VM SCSI support
        "sd_mod" # SCSI disk support
        "sr_mod" # SCSI CD-ROM support
        "btrfs" # Btrfs filesystem support
      ];
    };

    supportedFilesystems = [ "btrfs" ];
  };

  networking = {
    hostName = "nixos"; # Define your hostname.

    useDHCP = lib.mkForce true;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH (VERY IMPORTANT!)
        80 # HTTP
        443 # HTTPS
        2377 # Cluster management communications
        4789 # Overlay network traffic
        3000 # Dokploy
        7946 # Container network discovery
      ];
      allowedUDPPorts = [
        4789 # Overlay network traffic
        7946 # Container network discovery
      ];
    };
    # Enable networking
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "it2";

  programs.zsh.enable = true;

  users.users.admin = {
    isNormalUser = true;
    description = "admin";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    hashedPassword =
      "$6$5gYC2ZrWG.OHl0q4$DvISykmVofwrst9BBtFPw3wDFPBa0marCybZMP42a4YJIJGCCL9c4WLM56Pv1.5V1oO5/8eLRwyVtV3aO1pxk1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAqgfcNv5MLfj2+2f7UGB7yu4d7NwPNxxNdINwOATFGzW+w15yOimWneGbUKaAX+YV9fyebpX7CinsvEbHIyQVMw32e6CEW9lDtFtlTQLIYbKYglIDgaris1hZxkvYKUG3FgFYxDqG5yKVB9G3/uPBl8CAMAmYBPu2d+YGqmVw/NT31kWqfbBFyIsQq/PdxP1S0kx9ng1GfCVsfqTGJ9SNZIp2jTFHnIckp7hajJSDzucNVygfHApkQrA4jJ9RSzDZ/XWtlK3XFf0WE5qqsW6qhkJ47BI438vhYXz8y8b9X7qqGwoMIzY3Z+uS6/kVgvUXiHlslB8Xt1WzW2mFi7yH29gzThwqm5A/Noo6W7K++FBaMWZBkSO7naw02b/SRtyjeiiwkvsNv4+Iwyiwr/DCinz6IgngRvLEkOJcMCQ0Mert/VH8VK8AANqKrSmREQM8164gQHFyavOz7c2GGDOyWbIv9lWXjvjN5jxlFw8IErWMnqv/TqIo998yykeEGTE="
    ];
  };

  users.users.root = {

    hashedPassword =
      "$6$5gYC2ZrWG.OHl0q4$DvISykmVofwrst9BBtFPw3wDFPBa0marCybZMP42a4YJIJGCCL9c4WLM56Pv1.5V1oO5/8eLRwyVtV3aO1pxk1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAqgfcNv5MLfj2+2f7UGB7yu4d7NwPNxxNdINwOATFGzW+w15yOimWneGbUKaAX+YV9fyebpX7CinsvEbHIyQVMw32e6CEW9lDtFtlTQLIYbKYglIDgaris1hZxkvYKUG3FgFYxDqG5yKVB9G3/uPBl8CAMAmYBPu2d+YGqmVw/NT31kWqfbBFyIsQq/PdxP1S0kx9ng1GfCVsfqTGJ9SNZIp2jTFHnIckp7hajJSDzucNVygfHApkQrA4jJ9RSzDZ/XWtlK3XFf0WE5qqsW6qhkJ47BI438vhYXz8y8b9X7qqGwoMIzY3Z+uS6/kVgvUXiHlslB8Xt1WzW2mFi7yH29gzThwqm5A/Noo6W7K++FBaMWZBkSO7naw02b/SRtyjeiiwkvsNv4+Iwyiwr/DCinz6IgngRvLEkOJcMCQ0Mert/VH8VK8AANqKrSmREQM8164gQHFyavOz7c2GGDOyWbIv9lWXjvjN5jxlFw8IErWMnqv/TqIo998yykeEGTE="
    ];
  };

  # Enable automatic login for the user.
  services = {
    # For proper btrfs support
    btrfs.autoScrub.enable = true;

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        AllowUsers = null; # Allows all users by default.
        UseDns = true;
        X11Forwarding = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    # Enable fail2ban to protect against brute-force attacks.
    fail2ban = {
      enable = true;
      # Ban IP after 5 failures
      maxretry = 5;
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        formula =
          "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
      ignoreIP = [
        # Whitelist some subnets
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "8.8.8.8" # whitelist a specific IP
        "nixos.wiki" # resolve the IP via DNS
      ];
      jails = {
        sshd.settings = {
          enabled = true;
          port = 22;
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = 5;
          findtime = 600;
          bantime = 600;
        };
      };
    };
  };

  # Enable nix flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "admin" "@wheel" ];
  };

  # Allow admin user to use sudo without password (REMOVE THIS IN PRODUCTION)
  security.sudo.extraRules = [{
    users = [ "admin" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      btop
      curl
      fastfetch
      fzf
      git
      htop
      nmap
      stow
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      zoxide
    ];
  };

  system.stateVersion = "24.11";
}
