{
  description = "NixOS Server configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-anywhere.url = "github:numtide/nixos-anywhere";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, sops-nix, disko, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        provisioning = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            disko.nixosModules.disko
            ./hosts/generic/disk-configuration.nix
            sops-nix.nixosModules.sops
            ./hosts/generic/default.nix
            home-manager.nixosModules.home-manager
            ./hosts/generic/home.nix
          ];
        };

        server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            sops-nix.nixosModules.sops
            ./hosts/generic/default.nix
            ./hosts/generic/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            ./hosts/generic/home.nix
          ];
        };

        zimablade-provisioning = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            disko.nixosModules.disko
            ./hosts/zimablade/disk-configuration.nix
            sops-nix.nixosModules.sops
            ./hosts/zimablade/default.nix
            home-manager.nixosModules.home-manager
            ./hosts/zimablade/home.nix
          ];
        };

        zimablade = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            sops-nix.nixosModules.sops
            ./hosts/zimablade/default.nix
            ./hosts/zimablade/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            ./hosts/zimablade/home.nix
          ];
        };
      };
    };
}
