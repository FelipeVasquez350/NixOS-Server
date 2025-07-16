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

  outputs = { self, nixpkgs, sops-nix, disko, home-manager, ... }@inputs: {
    nixosConfigurations = {

      genericServer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/generic/default.nix
          disko.nixosModules.disko
          ./hosts/generic/disk-configuration.nix
          home-manager.nixosModules.home-manager
          ./hosts/generic/home.nix
          ./profiles/dokploy.nix
        ];
      };

      kubernetesDev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/generic/default.nix
          disko.nixosModules.disko
          ./hosts/generic/disk-configuration.nix
          home-manager.nixosModules.home-manager
          ./hosts/generic/home.nix
          ./profiles/kubernetes-dev.nix
        ];
      };

      zimablade = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/zimablade/default.nix
          disko.nixosModules.disko
          ./hosts/zimablade/disk-configuration.nix
          home-manager.nixosModules.home-manager
          ./hosts/zimablade/home.nix
          ./profiles/zima.nix
        ];
      };
    };

    packages.x86_64-linux = {
      genericImage = (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/generic/default.nix
          disko.nixosModules.disko
          ./hosts/generic/disk-configuration.nix
          home-manager.nixosModules.home-manager
          ./hosts/generic/home.nix
          ./profiles/dokploy.nix
          ({ ... }: {
            disko.devices.disk.main = {
              imageSize = "4G";
              imageName = "generic";
            };
            boot.loader.timeout = 15;
          })
        ];
      }).config.system.build.diskoImagesScript;

      kubernetesImage = (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/generic/default.nix
          disko.nixosModules.disko
          ./hosts/generic/disk-configuration.nix
          home-manager.nixosModules.home-manager
          ./hosts/generic/home.nix
          ./profiles/kubernetes-dev.nix
          ({ ... }: {
            disko.devices.disk.main = {
              imageSize = "4G";
              imageName = "kube";
            };
            boot.loader.timeout = 15;
          })
        ];
      }).config.system.build.diskoImagesScript;

      zimablade = (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/zimablade/default.nix
          disko.nixosModules.disko
          ./hosts/zimablade/disk-configuration.nix
          home-manager.nixosModules.home-manager
          ./hosts/zimablade/home.nix
          ./profiles/zima.nix
          ({ ... }: {
            disko.devices.disk.mmcblk0 = {
              imageSize = "4G";
              imageName = "zimablade";
            };
            boot.loader.timeout = 15;
          })
        ];
      }).config.system.build.diskoImagesScript;
    };
  };
}
