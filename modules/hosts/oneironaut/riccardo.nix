{ self, inputs, ... }: {
  flake.homeModules.riccardo = { config, pkgs, ... }: {
    home.username = "riccardo";
    home.homeDirectory = "/home/riccardo";
    home.stateVersion = "25.11";
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    home.packages = with pkgs; [
	  spotify
	  imv
	  wl-clipboard
	  thunar
	  gnome-calculator
	  direnv
	  git
	  ripgrep
	  claude-code
	  openvpn
	  slack
	  easyeffects
	  freecad
	  # cura-appimage
	  nettools
	  wdisplays
	  system-config-printer
	  croc
	  pulseaudio
	  alsa-utils
	  overskride
	  fastfetch
	  fd
	  tree-sitter
	  jq
    ];
	# Colors come from noctalia (modules/features/noctalia.nix). catppuccin/nix
	# only covers what has no noctalia template that works with HM-managed configs.
	catppuccin.enable = false;
	catppuccin.starship.enable = true;
	catppuccin.mpv.enable = true;

	# Show Thunar with the (palette-colored) folder icon in launchers: same entry,
	# shadowing the packaged one, with only Icon= changed. Absolute path because
	# fuzzel only looks up names in the themes' "apps" dirs and `folder` is in
	# "places"; this is the copy the noctalia papirus-icons hook recolors.
	xdg.dataFile."applications/thunar.desktop".source =
		pkgs.runCommand "thunar.desktop" { } ''
			sed 's|^Icon=.*|Icon=${config.xdg.dataHome}/icons/Papirus-Dark/128x128/places/folder.svg|' \
				${pkgs.thunar}/share/applications/thunar.desktop > $out
		'';
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
	  self.homeModules.noctalia
    ];
  };
}
