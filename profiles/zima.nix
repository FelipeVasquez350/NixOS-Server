{ pkgs, ... }:

{
  users = {
    groups.podmanager = { };
    users.podmanager = {
      isSystemUser = true;
      group = "podmanager";
      home = "/home/podmanager";
      createHome = true;
      description = "User for running podman containers";
    };
  };
  # Use Podman instead of Docker for reduced storage requirements
  virtualisation = {
    podman = {
      enable = true;

      # Enable Docker compatibility
      dockerCompat = true;

      # Reduce storage usage
      autoPrune = {
        enable = true;
        dates = "daily";
        flags = [ "--all" ];
      };

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      # Default to overlayfs storage for better efficiency
      defaultNetwork.settings.driver = "bridge";

      extraPackages = [ pkgs.cni-plugins ];
    };
  };

  imports = [
    ../modules/services/rathole.nix
    ../modules/services/wireguard.nix
    ../modules/services/cloudflared.nix
    ../modules/monitoring.nix
  ];
}
