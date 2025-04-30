{ pkgs, config, lib, inputs ? null, ... }: {
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
          labels =
            "app_id,container_name"; # Add more useful labels for filtering
        };
        experimental =
          true; # Enable experimental features that might help with log collection
      };
      extraOptions = "--metrics-addr 127.0.0.1:9323";
      # Only use btrfs driver if the filesystem is btrfs
      storageDriver =
        lib.mkIf (config.fileSystems."/".fsType == "btrfs") "btrfs";
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
        "PATH" = lib.mkForce
          "${pkgs.curl}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
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
        "PATH" = lib.mkForce
          "${pkgs.docker}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
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
        "PATH" = lib.mkForce
          "${pkgs.docker}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
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

  environment.variables = { PATH = [ "/usr/bin" "$PATH" ]; };
}
