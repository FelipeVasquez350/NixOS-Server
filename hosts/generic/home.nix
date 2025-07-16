{ config, pkgs, lib, ... }:

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
      ".config/tmux/tmux.conf".source = ../../dotfiles/.config/tmux/tmux.conf;
    };
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
    home.stateVersion = "24.11";
  };

  home-manager.users.root = { ... }: {
    home.username = "root";
    home.homeDirectory = "/root";
    home.file = {
      ".zshrc".source = ../../dotfiles/.zshrc;
      ".p10k.zsh".source = ../../dotfiles/.p10k.zsh;
      ".config/tmux/tmux.conf".source = ../../dotfiles/.config/tmux/tmux.conf;
    };
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
    home.stateVersion = "24.11";
  };

  # System service to install tmux plugins directly
  systemd.services.install-tmux-plugins = {
    description = "Install Tmux Plugins";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.git ];
    script = ''
      # Function to install plugins for a user
      install_plugins() {
        local user_home=$1
        local user_name=$2

        mkdir -p "$user_home/.config/tmux/plugins"

        # Install TPM
        if [ ! -d "$user_home/.config/tmux/plugins/tpm" ]; then
          git clone https://github.com/tmux-plugins/tpm "$user_home/.config/tmux/plugins/tpm"
        fi

        # Install tmux-sensible
        if [ ! -d "$user_home/.config/tmux/plugins/tmux-sensible" ]; then
          git clone https://github.com/tmux-plugins/tmux-sensible "$user_home/.config/tmux/plugins/tmux-sensible"
        fi

        # Install vim-tmux-navigator
        if [ ! -d "$user_home/.config/tmux/plugins/vim-tmux-navigator" ]; then
          git clone https://github.com/christoomey/vim-tmux-navigator "$user_home/.config/tmux/plugins/vim-tmux-navigator"
        fi

        # Install dreamsofcode-io/catppuccin-tmux
        if [ ! -d "$user_home/.config/tmux/plugins/catppuccin-tmux" ]; then
          git clone https://github.com/dreamsofcode-io/catppuccin-tmux "$user_home/.config/tmux/plugins/catppuccin-tmux"
        fi

        # Set ownership for admin user
        if [ "$user_name" = "admin" ]; then
          chown -R admin:users "$user_home/.config/tmux"
        fi
      }

      # Install for admin user
      install_plugins "/home/admin" "admin"

      # Install for root user
      install_plugins "/root" "root"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
