{
  description = "NixOS Server configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-anywhere.url = "github:numtide/nixos-anywhere";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-anywhere, disko, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        provisioning = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            disko.nixosModules.disko
            ./disk-configuration.nix
            ./configuration.nix
            home-manager.nixosModules.home-manager
            ./home.nix
          ];
        };

        server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            home-manager.nixosModules.home-manager
            ./home.nix
          ];
        };

        digitalocean = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            { disko.devices.disk.disk1.device = "/dev/vda"; }
            {
              # do not use DHCP, as DigitalOcean provisions IPs using cloud-init
              networking.useDHCP = nixpkgs.lib.mkForce false;
                 services.cloud-init = {
                enable = true;
                network.enable = true;
                settings = {
                  datasource_list = [ "ConfigDrive" ];
                  datasource.ConfigDrive = { };
                };
              };
            }
            ./configuration.nix
          ];
        };
      };
  };
}
