{ config, pkgs, ... }:

{
  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
    home = "/home/cloudflared";
    createHome = true;
    description = "User for running cloudflared";
  };

  environment.systemPackages = with pkgs; [ cloudflared ];

  # https://wiki.nixos.org/wiki/Cloudflared
  # Remember to copy the pem file too in cloudflared home/.cloudflared folder
  services.cloudflared = {
    enable = true;
    tunnels = {
      "00000000-0000-0000-0000-000000000000" = {
        credentialsFile = "${config.sops.secrets.cloudflared_credentials_file.path}";
        ingress = {
          "grafana.labs.felipe350.com" = {
            service = "http://127.0.0.1:6000";
          };

          "*.grafana.labs.felipe350.com" = {
            service = "http://127.0.0.1:6000";
            path = "/*.(jpg|png|css|js)";
          };
        };
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
