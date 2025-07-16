{ config, pkgs, ... }:

{
  users.groups.cloudflared = { };
  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
    home = "/home/cloudflared";
    createHome = true;
    description = "User for running cloudflared";
  };

  #https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
  boot.kernel.sysctl = {
    # UDP buffer size parameters
    "net.core.rmem_max" = 8388608; # 8MB max receive buffer
    "net.core.wmem_max" = 8388608; # 8MB max send buffer
  };

  environment.systemPackages = with pkgs; [ cloudflared ];

  # https://wiki.nixos.org/wiki/Cloudflared
  # Remember to copy the pem file too in cloudflared home/.cloudflared folder

  # Configure the cloudflared service
  services.cloudflared = {
    enable = true;
    tunnels = {
      "f37ae07f-6f4f-493f-af1b-434a059be1c8" = {
        credentialsFile = config.sops.secrets.cloudflared_credentials_file.path;

        # # Define ingress in NixOS config as well for consistency
        # ingress = {
        #   "grafana.felipe350.com" = {
        #     service = "http://127.0.0.1:6000";
        #   };
        #   "*.grafana.felipe350.com" = {
        #     service = "http://127.0.0.1:6000";
        #     path = "/*.(jpg|png|css|js)";
        #   };
        # };
        default = "http_status:404";
      };
    };
  };

  sops.secrets.cloudflared_credentials_file = {
    owner = "cloudflared";
    group = "cloudflared";
    mode = "0400";
  };
}
