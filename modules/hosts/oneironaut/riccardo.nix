{ self, inputs, ... }: {
  flake.homeModules.riccardo = { pkgs, ... }: {
    home.username = "riccardo";
    home.homeDirectory = "/home/riccardo";
    home.stateVersion = "25.11";
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    home.packages = with pkgs; [
	  spotify
	  imv
	  wl-clipboard
	  thunar
	  qalculate-gtk
	  direnv
	  git
	  ripgrep
	  claude-code
	  openfortivpn
	  openvpn
	  slack
      
    ];
	catppuccin.enable = true;
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
    ];
  };
}
