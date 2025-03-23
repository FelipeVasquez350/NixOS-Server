{ config, pkgs, ... }:

{
  # Common home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # User configurations
  home-manager.users.admin = { ... }: {
    home.file = {
      ".zshrc".source = ./dotfiles/.zshrc;
      ".p10k.zsh".source = ./dotfiles/.p10k.zsh;
    };
    home.stateVersion = "24.11";
  };

  home-manager.users.root = { ... }: {
    home.file = {
      ".zshrc".source = ./dotfiles/.zshrc;
      ".p10k.zsh".source = ./dotfiles/.p10k.zsh;
    };
    home.stateVersion = "24.11";
  };
}
