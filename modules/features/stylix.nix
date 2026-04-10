{ self, inputs, ... }: {
  flake.homeModules.stylix = { pkgs, lib, ... }: {
    imports = [ inputs.stylix.homeModules.stylix ];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";
	# image = ./wallpaper.png; # required even if you don't use it for colors
	  opacity.terminal = 0.95;  # moved here
		  fonts = {
			  monospace = {
				  package = pkgs.nerd-fonts.jetbrains-mono;
				  name = "JetBrainsMono Nerd Font";
			  };
			  sansSerif = {
				  package = pkgs.cantarell-fonts;
				  name = "Cantarell";
			  };
			  sizes = {
				  terminal = 13;    # this sets font size for all terminals including alacritty
				  applications = 12;
				  desktop = 12;
				  popups = 12;
			  };
		  };
	  iconTheme = {
		  enable = true;
		  package = pkgs.catppuccin-papirus-folders.override {
			  flavor = "mocha";
			  accent = "mauve";
		  };
		  dark = "Papirus-Dark";
		  light = "Papirus-Light";
	  };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };
    };
  };
}
