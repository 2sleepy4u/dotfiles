{ self, inputs, ... }: {
  flake.homeModules.im2sleepy = { pkgs, ... }: {
    home.username = "im2sleepy";
    home.homeDirectory = "/home/im2sleepy";
    home.stateVersion = "25.11";
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    home.packages = with pkgs; [
	  prismlauncher
	  spotify
	  imv
	  wl-clipboard
	  thunar
	  direnv
	  gnome-calculator
	  git
      jdk21
	  ripgrep
	  gparted

      (discord.override {
        commandLineArgs = [
          "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
          "--ozone-platform=wayland"
          "--enable-wayland-ime"
        ];
      })
    ];
	catppuccin.enable = false;
	# catppuccin.kvantum.enable = false;
stylix.targets.qt.enable = false;

    imports = [
	  inputs.catppuccin.homeModules.catppuccin
      self.homeModules.brave
      self.homeModules.neovim
	  self.homeModules.alacritty
	  self.homeModules.tmux
	  self.homeModules.starship
	  self.homeModules.zsh
	  self.homeModules.fuzzel
	  self.homeModules.mpv      # add this
	  self.homeModules.stylix      # add this

    ];
  };
}
