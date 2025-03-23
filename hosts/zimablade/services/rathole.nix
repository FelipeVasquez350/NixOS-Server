{ config, ... }:

let
  # Define the rathole config directory
  ratholeConfigDir = "/home/podmanager/rathole";
in
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      rathole-server = {
        image = "rapiz1/rathole:latest"; # https://hub.docker.com/r/rapiz1/rathole
        user = "1000:1000";  # Typical first user ID, adjust if needed
        # Mount the configuration file from the specified location
        volumes = [
          "${ratholeConfigDir}/server.toml:/etc/rathole/server.toml:ro"
        ];
        # Command to run rathole with the server config
        cmd = [ "--server" "/etc/rathole/server.toml" ];
        # Expose the necessary ports
        ports =  [
          "5000:5000"   # Control channel (from your config)
          "7777:7777"   # Generic
          "25535:25535" # Minecraft
        ];
      };
    };
  };
  # Configure the systemd service
  systemd.services.podman-rathole-server = {
    description = "Rathole Server Service";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    preStart = ''
      # Create config directory
      mkdir -p ${ratholeConfigDir}

      # Copy the base config file
      cp -f ${../../../config/server.toml} ${ratholeConfigDir}/server.toml.tmp

      # Replace the default token with the secret token
      token=$(cat ${config.sops.secrets.rathole_token.path})
      sed "s/default_token = \".*\"/default_token = \"$token\"/" ${ratholeConfigDir}/server.toml.tmp > ${ratholeConfigDir}/server.toml
      rm ${ratholeConfigDir}/server.toml.tmp

      # Ensure proper permissions
      chown -R podmanager:podmanager ${ratholeConfigDir}
      chmod 755 ${ratholeConfigDir}
      chmod 644 ${ratholeConfigDir}/server.toml
    '';

    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
    };
  };

  # Configure sops secret
  sops.secrets.rathole_token = {
    owner = "podmanager";
    group = "podmanager";
    mode = "0400";
  };

  # Make sure the firewall allows the needed ports from your config
  networking.firewall = {
    allowedTCPPorts = [
      5000   # Rathole control channel
      7777   # Generic port
      25535  # Minecraft port
    ];
  };
}
