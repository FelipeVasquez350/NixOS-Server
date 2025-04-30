{ config, pkgs, ... }:

{
  # Common home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # User configurations
  home-manager.users.admin = { ... }: {
    home.username = "admin";
    home.homeDirectory = "/home/admin";
    home.file = {
      ".zshrc".source = ../../dotfiles/.zshrc;
      ".p10k.zsh".source = ../../dotfiles/.p10k.zsh;
    };
    home.stateVersion = "24.11";
  };

  home-manager.users.root = { ... }: {
    home.username = "root";
    home.homeDirectory = "/root";
    home.file = {
      ".zshrc".source = ../../dotfiles/.zshrc;
      ".p10k.zsh".source = ../../dotfiles/.p10k.zsh;
    };
    home.stateVersion = "24.11";
  };
}
