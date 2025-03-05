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
        6001  # Websocket for Coolify
        6002  # Terminalo for Coolify
        7946  # Container network discovery
        9000  # Needed by Coolify but idk why
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
    hashedPassword = "$6$M4mfMkIbsR/brcBr$R4W.rNN.c8YSpmwHvv73lcM/r.3.EOZV/EwfblUuaQCDkUb5Ez9yT4EK1yeD60l3b1ZqxQwsMx4P5WOEb2yhM/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAqgfcNv5MLfj2+2f7UGB7yu4d7NwPNxxNdINwOATFGzW+w15yOimWneGbUKaAX+YV9fyebpX7CinsvEbHIyQVMw32e6CEW9lDtFtlTQLIYbKYglIDgaris1hZxkvYKUG3FgFYxDqG5yKVB9G3/uPBl8CAMAmYBPu2d+YGqmVw/NT31kWqfbBFyIsQq/PdxP1S0kx9ng1GfCVsfqTGJ9SNZIp2jTFHnIckp7hajJSDzucNVygfHApkQrA4jJ9RSzDZ/XWtlK3XFf0WE5qqsW6qhkJ47BI438vhYXz8y8b9X7qqGwoMIzY3Z+uS6/kVgvUXiHlslB8Xt1WzW2mFi7yH29gzThwqm5A/Noo6W7K++FBaMWZBkSO7naw02b/SRtyjeiiwkvsNv4+Iwyiwr/DCinz6IgngRvLEkOJcMCQ0Mert/VH8VK8AANqKrSmREQM8164gQHFyavOz7c2GGDOyWbIv9lWXjvjN5jxlFw8IErWMnqv/TqIo998yykeEGTE="
    ];
  };

  users.users.root = {
    hashedPassword = "$6$M4mfMkIbsR/brcBr$R4W.rNN.c8YSpmwHvv73lcM/r.3.EOZV/EwfblUuaQCDkUb5Ez9yT4EK1yeD60l3b1ZqxQwsMx4P5WOEb2yhM/";
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

    coolify-setup = {
      description = "Setup Coolify";
      requires = [ "docker-swarm-init.service" ];
      after = [ "docker-swarm-init.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.docker pkgs.curl pkgs.openssl ];
      environment = {
        "PATH" = lib.mkForce "${pkgs.docker}/bin:${pkgs.curl}/bin:${pkgs.openssl}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Make ssh directory if it doesn't exist
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh

        # Create coolify network first - make sure it exists before we try to use it
        if ! docker network ls | grep -q coolify; then
        docker network create --attachable coolify
        fi

        # Create base directories for Coolify
        mkdir -p /data/coolify/{source,ssh,applications,databases,backups,services,proxy,webhooks-during-maintenance}
        mkdir -p /data/coolify/ssh/{keys,mux}
        mkdir -p /data/coolify/proxy/dynamic

        # Generate SSH key for Coolify to manage server if it doesn't exist
        if [ ! -f /data/coolify/ssh/keys/id.root@host.docker.internal ]; then
          ssh-keygen -f /data/coolify/ssh/keys/id.root@host.docker.internal -t ed25519 -N "" -C root@coolify
          # Add the public key to authorized_keys
          cat /data/coolify/ssh/keys/id.root@host.docker.internal.pub >> ~/.ssh/authorized_keys
          chmod 600 ~/.ssh/authorized_keys
        fi

        # Download configuration files if they don't exist
        if [ ! -f /data/coolify/source/docker-compose.yml ]; then
          curl -fsSL https://cdn.coollabs.io/coolify/docker-compose.yml -o /data/coolify/source/docker-compose.yml
        fi

        if [ ! -f /data/coolify/source/docker-compose.prod.yml ]; then
          curl -fsSL https://cdn.coollabs.io/coolify/docker-compose.prod.yml -o /data/coolify/source/docker-compose.prod.yml
        fi

        if [ ! -f /data/coolify/source/.env ]; then
          curl -fsSL https://cdn.coollabs.io/coolify/.env.production -o /data/coolify/source/.env

          # Generate secure random values for .env file
          sed -i "s|APP_ID=.*|APP_ID=$(openssl rand -hex 16)|g" /data/coolify/source/.env
          sed -i "s|APP_KEY=.*|APP_KEY=base64:$(openssl rand -base64 32)|g" /data/coolify/source/.env
          sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$(openssl rand -base64 32)|g" /data/coolify/source/.env
          sed -i "s|REDIS_PASSWORD=.*|REDIS_PASSWORD=$(openssl rand -base64 32)|g" /data/coolify/source/.env
          sed -i "s|PUSHER_APP_ID=.*|PUSHER_APP_ID=$(openssl rand -hex 32)|g" /data/coolify/source/.env
          sed -i "s|PUSHER_APP_KEY=.*|PUSHER_APP_KEY=$(openssl rand -hex 32)|g" /data/coolify/source/.env
          sed -i "s|PUSHER_APP_SECRET=.*|PUSHER_APP_SECRET=$(openssl rand -hex 32)|g" /data/coolify/source/.env
        fi

        if [ ! -f /data/coolify/source/upgrade.sh ]; then
          curl -fsSL https://cdn.coollabs.io/coolify/upgrade.sh -o /data/coolify/source/upgrade.sh
        fi

        # Set proper permissions
        chown -R 9999:root /data/coolify
        chmod -R 700 /data/coolify

        # Start Coolify if not already running
        if ! docker ps | grep -q coolify-api; then
          cd /data/coolify/source && \
          docker compose --env-file /data/coolify/source/.env \
            -f /data/coolify/source/docker-compose.yml \
            -f /data/coolify/source/docker-compose.prod.yml \
            up -d --pull always --remove-orphans --force-recreate
        fi
      '';
    };
  };

  environment.variables = {
    PATH = [
      "/usr/bin"
      "$PATH"
    ];
  };

  # Enable automatic login for the user.
  services = {
    getty = {
      autologinUser = "admin";
      helpLine = "";
      extraArgs = [ "--noclear" ];
    };

    # Enable the OpenSSH daemon.
    openssh= {
      enable = true;
      ports = [ 22 ];
      settings = {
        # PasswordAuthentication = false;
        AllowUsers = null; # Allows all users by default.
        UseDns = true;
        X11Forwarding = false;
        # PermitRootLogin = "prohibit-password";
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
  environment.systemPackages = with pkgs; [
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

  system.stateVersion = "24.11";
}
