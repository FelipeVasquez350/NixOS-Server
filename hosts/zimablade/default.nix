{ pkgs, ... }:

{
  # Bootloader with minimal generation retention
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 2;  # Extremely limited generations
        editor = false;  # Disable boot editing for security
      };
      efi.canTouchEfiVariables = true;
    };

    # Minimal kernel
    kernelPackages = pkgs.linuxPackages_hardened;

    # Only support essential filesystems
    supportedFilesystems = [ "vfat" "ext4" ];

    # Enable tmpfs for /tmp
    tmp = {
      tmpfsSize = "256M";
      useTmpfs = true;
    };

    # Limit the initrd size
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = [
        "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi"
        "sd_mod" "sr_mod" "mmc_block" "sdhci" "sdhci_pci"
      ];
      kernelModules = [ "mmc_block" ];
    };
  };

  # Optimize filesystems for storage efficiency
  fileSystems = {
    "/".options = [ "noatime" "commit=60" "barrier=0" ];
    "/boot".options = [ "defaults" "noatime" ];
  };

  # SOPS for secrets management
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # Use zram for swap instead of disk
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Network configuration
  networking = {
    hostName = "blade";

    # Use systemd-networkd (lighter than NetworkManager)
    useNetworkd = true;
    useDHCP = true;

    nameservers = [ "8.8.8.8" "8.8.4.4" ];

    # Minimal firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH
        80    # HTTP
        443   # HTTPS
        3000  # App service (if needed)
      ];
      # Log dropped packets for security visibility
      logRefusedConnections = true;
    };
  };

  systemd.network = {
    enable = true;

    # Universal DHCP fallback for your primary interface
    networks."10-dhcp" = {
      matchConfig = {
        Name = "enp2s0";  # Your ethernet interface
      };
      networkConfig = {
        DHCP = "yes";
        # Let DHCP set everything including gateway
        # No static addressing
      };
      # Use these if you need DHCP to behave in specific ways
      dhcpV4Config = {
        UseDNS = true;
        UseRoutes = true;  # Let DHCP provide the routes
        SendHostname = true;
      };
    };
  };

  # Time and locale
  time.timeZone = "Europe/Rome";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "it_IT.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
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
  };

  # Console configuration
  console.keyMap = "it2";

  # Enable ZSH for better shell experience
  programs.zsh.enable = true;

  # User setup with minimal shell
  users = {
    mutableUsers = false; # Make users immutable for security
    users.zima = {
      isNormalUser = true;
      description = "zima";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      hashedPassword = "$6$5gYC2ZrWG.OHl0q4$DvISykmVofwrst9BBtFPw3wDFPBa0marCybZMP42a4YJIJGCCL9c4WLM56Pv1.5V1oO5/8eLRwyVtV3aO1pxk1";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAqgfcNv5MLfj2+2f7UGB7yu4d7NwPNxxNdINwOATFGzW+w15yOimWneGbUKaAX+YV9fyebpX7CinsvEbHIyQVMw32e6CEW9lDtFtlTQLIYbKYglIDgaris1hZxkvYKUG3FgFYxDqG5yKVB9G3/uPBl8CAMAmYBPu2d+YGqmVw/NT31kWqfbBFyIsQq/PdxP1S0kx9ng1GfCVsfqTGJ9SNZIp2jTFHnIckp7hajJSDzucNVygfHApkQrA4jJ9RSzDZ/XWtlK3XFf0WE5qqsW6qhkJ47BI438vhYXz8y8b9X7qqGwoMIzY3Z+uS6/kVgvUXiHlslB8Xt1WzW2mFi7yH29gzThwqm5A/Noo6W7K++FBaMWZBkSO7naw02b/SRtyjeiiwkvsNv4+Iwyiwr/DCinz6IgngRvLEkOJcMCQ0Mert/VH8VK8AANqKrSmREQM8164gQHFyavOz7c2GGDOyWbIv9lWXjvjN5jxlFw8IErWMnqv/TqIo998yykeEGTE="
      ];
    };

    groups.podmanager = {};
    users.podmanager = {
      isSystemUser = true;
      group = "podmanager";
      home = "/home/podmanager";
      createHome = true;
      description = "User for running podman containers";
    };
  };

  # Podman instead of Docker for reduced storage requirements
  virtualisation = {
    podman = {
      enable = true;

      # Enable Docker compatibility
      dockerCompat = true;

      # Reduce storage usage
      autoPrune = {
        enable = true;
        dates = "daily";
        flags = ["--all"];
      };

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      # Default to overlayfs storage for better efficiency
      defaultNetwork.settings.driver = "bridge";
    };
  };

  # Essential services only
  services = {
    # SSH configuration (essential)
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
      };
      # Hardening
      extraConfig = ''
        AllowTcpForwarding yes
        ClientAliveCountMax 2
        Compression no
        MaxAuthTries 3
        MaxSessions 2
      '';
    };

    # Enable fail2ban to protect against brute-force attacks.
    fail2ban = {
      enable = true;
      # Ban IP after 5 failures
      maxretry = 5;
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
      ignoreIP = [
        # Whitelist some subnets
        "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
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

    # Limit journal size
    journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=10M
      MaxFileSec=1day
      Storage=volatile
    '';

    # No need for unused services
    printing.enable = false;
    avahi.enable = false;
    pipewire.enable = false;
    xserver.enable = false;
  };

  # Enhanced aggressive storage management
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "admin" "@wheel" ];
      # Keep the store small
      min-free = 64000000;  # 64MB minimum free
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };

    # Enable flakes
    settings.experimental-features = ["nix-command" "flakes"];

    # Optimize storage usage
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  # Security hardening that uses minimal resources
  security = {
    sudo.extraRules = [{
      users = [ "zima" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];

    # Disable unnecessary security services
    polkit.enable = false;
    rtkit.enable = false;

    # No audit subsystem overhead
    audit.enable = false;
  };

  # Allow unfree packages if needed
  nixpkgs.config.allowUnfree = true;

  # Minimal system packages - extremely limited
  environment = {
    systemPackages = with pkgs; [
      btop
      curl
      fastfetch
      fzf
      git
      stow
      vim
      wget
      zoxide
    ];
  };

  # Skip documentation to save space
  documentation = {
    enable = false;
    man.enable = false;
    doc.enable = false;
    info.enable = false;
  };

  # Clean /tmp regularly
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root 1d"
  ];

  imports = [
    ./services/rathole.nix
    ./services/wireguard.nix
  ];

  # Important: Version marker
  system.stateVersion = "23.11"; # Use a stable version
}
