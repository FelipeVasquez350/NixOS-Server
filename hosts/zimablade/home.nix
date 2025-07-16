{
  # Common home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # User configurations
  home-manager.users.zima = { ... }: {
    home.file = {
      ".zshrc".source = ../../dotfiles/.zshrc;
      ".p10k.zsh".source = ../../dotfiles/.p10k.zsh;
      ".config/tmux".source = ../../dotfiles/.config/tmux;
    };
    home.stateVersion = "24.11";
  };
}
