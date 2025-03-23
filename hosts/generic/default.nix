# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # Bootloader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;  # Limit the number of generations
        # Make /boot more secure
        editor = false;  # Disable boot entry editing
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"
      ];
      kernelModules = [ "virtio_pci" "virtio_scsi" ];
    };
    # Add any needed kernel modules
    kernelModules = [ "virtio_pci" "virtio_scsi" ];
  };

  fileSystems."/boot" = {
    options = [ "defaults" "noatime" "dmask=0077" "fmask=0077" ];
  };

  networking= {
    hostName = "nixos"; # Define your hostname.
    interfaces.ens3 = {  # Replace "ens3" with your network interface name
      ipv4.addresses = [{
        address = "192.168.178.200";  # Your desired static IP
        prefixLength = 24;            # Subnet mask (24 = 255.255.255.0)
      }];
      useDHCP = false;
    };
    defaultGateway = "192.168.178.1";  # Your router's IP address
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH (VERY IMPORTANT!)
        80    # HTTP
        443   # HTTPS
        2377  # Cluster management communications
        4789  # Overlay network traffic
        3000  # Dokploy
        7946  # Container network discovery
      ];
      allowedUDPPorts = [
        4789  # Overlay network traffic
        7946  # Container network discovery
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
    hashedPassword = "$6$5gYC2ZrWG.OHl0q4$DvISykmVofwrst9BBtFPw3wDFPBa0marCybZMP42a4YJIJGCCL9c4WLM56Pv1.5V1oO5/8eLRwyVtV3aO1pxk1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAqgfcNv5MLfj2+2f7UGB7yu4d7NwPNxxNdINwOATFGzW+w15yOimWneGbUKaAX+YV9fyebpX7CinsvEbHIyQVMw32e6CEW9lDtFtlTQLIYbKYglIDgaris1hZxkvYKUG3FgFYxDqG5yKVB9G3/uPBl8CAMAmYBPu2d+YGqmVw/NT31kWqfbBFyIsQq/PdxP1S0kx9ng1GfCVsfqTGJ9SNZIp2jTFHnIckp7hajJSDzucNVygfHApkQrA4jJ9RSzDZ/XWtlK3XFf0WE5qqsW6qhkJ47BI438vhYXz8y8b9X7qqGwoMIzY3Z+uS6/kVgvUXiHlslB8Xt1WzW2mFi7yH29gzThwqm5A/Noo6W7K++FBaMWZBkSO7naw02b/SRtyjeiiwkvsNv4+Iwyiwr/DCinz6IgngRvLEkOJcMCQ0Mert/VH8VK8AANqKrSmREQM8164gQHFyavOz7c2GGDOyWbIv9lWXjvjN5jxlFw8IErWMnqv/TqIo998yykeEGTE="
    ];
  };

  users.users.root = {
    hashedPassword = "$6$5gYC2ZrWG.OHl0q4$DvISykmVofwrst9BBtFPw3wDFPBa0marCybZMP42a4YJIJGCCL9c4WLM56Pv1.5V1oO5/8eLRwyVtV3aO1pxk1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAqgfcNv5MLfj2+2f7UGB7yu4d7NwPNxxNdINwOATFGzW+w15yOimWneGbUKaAX+YV9fyebpX7CinsvEbHIyQVMw32e6CEW9lDtFtlTQLIYbKYglIDgaris1hZxkvYKUG3FgFYxDqG5yKVB9G3/uPBl8CAMAmYBPu2d+YGqmVw/NT31kWqfbBFyIsQq/PdxP1S0kx9ng1GfCVsfqTGJ9SNZIp2jTFHnIckp7hajJSDzucNVygfHApkQrA4jJ9RSzDZ/XWtlK3XFf0WE5qqsW6qhkJ47BI438vhYXz8y8b9X7qqGwoMIzY3Z+uS6/kVgvUXiHlslB8Xt1WzW2mFi7yH29gzThwqm5A/Noo6W7K++FBaMWZBkSO7naw02b/SRtyjeiiwkvsNv4+Iwyiwr/DCinz6IgngRvLEkOJcMCQ0Mert/VH8VK8AANqKrSmREQM8164gQHFyavOz7c2GGDOyWbIv9lWXjvjN5jxlFw8IErWMnqv/TqIo998yykeEGTE="
    ];
  };

  virtualisation = {
    docker = {
      enable = true;
      # extraOptions = "--default-address-pool base=172.30.0.0/16,size=24";
      autoPrune.enable = true;
      daemon.settings = {
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
          labels = "app_id,container_name";  # Add more useful labels for filtering
        };
        experimental = true;  # Enable experimental features that might help with log collection
      };
      extraOptions = "--metrics-addr 127.0.0.1:9323";
      # Only use btrfs driver if the filesystem is btrfs
      storageDriver = lib.mkIf (config.fileSystems."/".fsType == "btrfs") "btrfs";
    };
  };

  systemd.services = {
    dops-setup = {
      description = "Setup Better Docker PS";
      requires = [ "docker.service" ];
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      # Specify the path to the packages needed for the script
      path = [ pkgs.curl ];
      environment = {
        "PATH" = lib.mkForce "${pkgs.curl}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
      };

      script = ''
        # Install Better Docker PS
        curl -L "https://github.com/Mikescher/better-docker-ps/releases/latest/download/dops_linux-amd64-static" -o "/usr/bin/dops" && chmod +x "/usr/bin/dops"
      '';
    };

    docker-swarm-init = {
      description = "Docker Swarm Init";
      requires = [ "docker.service" ];
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.docker ];
      # Use mkForce to override default PATH setting
      environment = {
        "PATH" = lib.mkForce "${pkgs.docker}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Check if already in a swarm
        if ! docker node ls >/dev/null 2>&1; then
        docker swarm init --advertise-addr 192.168.178.200
        fi
      '';
    };

    dokploy-setup = {
      description = "Setup Dokploy";
      requires = [ "docker-swarm-init.service" ];
      after = [ "docker-swarm-init.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.docker ];
      # Use mkForce to override default PATH setting
      environment = {
        "PATH" = lib.mkForce "${pkgs.docker}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
      # Create dokploy network if it doesn't exist
      if ! docker network ls | grep -q dokploy-network; then
        docker network create --driver overlay --attachable dokploy-network
      fi

      # Create dokploy directory
      mkdir -p /etc/dokploy
      chmod 777 /etc/dokploy

      # Deploy dokploy service if it doesn't exist
      if ! docker service ls | grep -q dokploy; then
        docker service create \
          --name dokploy \
          --replicas 1 \
          --network dokploy-network \
          --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
          --mount type=bind,source=/etc/dokploy,target=/etc/dokploy \
          --publish published=3000,target=3000,mode=host \
          --update-parallelism 1 \
          --update-order stop-first \
          dokploy/dokploy:latest
      fi
    '';
    };
  };

  # Enable automatic login for the user.
  services = {
    # Enable the OpenSSH daemon.
    openssh= {
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
  };

  # Enable nix flakes
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
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

    variables = {
      PATH = [
        "/usr/bin"
        "$PATH"
      ];
    };
  };

  system.stateVersion = "24.11";
}
