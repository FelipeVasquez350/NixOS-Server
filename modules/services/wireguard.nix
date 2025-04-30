{ config, pkgs, ... }:
{
  # Enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp2s0";
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  # Install wireguard tools for management
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  # Configure IP forwarding at the system level
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  systemd.network = {
    netdevs."10-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
        Description = "WireGuard VPN";
      };

      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wireguard_private_key.path;
        ListenPort = 51820;
      };

      # Define peer configurations
      wireguardPeers = [
        {
          PublicKey = "mleN1e80wSwm6pnewzBL0IThe7N50DYroNd0LULjyTc="; # Mobile
          AllowedIPs = [ "10.100.0.2/32" ];
        }
        {
          PublicKey = "9l8FJ0dtPgygxQi/qPTMsh//Zf4osXGSehoXTa5mlFM="; # Laptop
          AllowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };

    # Configure the network settings for the WireGuard interface
    networks."20-wg0" = {
      matchConfig.Name = "wg0";
      addresses = [
        { Address = "10.100.0.1/24"; }
      ];
    };
  };

  # Make sure the secret can be read by systemd-networkd
  sops.secrets.wireguard_private_key = {
    owner = "systemd-network";
    group = "systemd-network";
    mode = "0400";
  };
}
