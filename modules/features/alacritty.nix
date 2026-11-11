{ self, inputs, ... }: {
	flake.homeModules.alacritty = { pkgs, lib, ... }: {
		fonts.fontconfig.enable = true;

		home.packages = [
			pkgs.nerd-fonts.jetbrains-mono
			pkgs.eb-garamond
		];
		programs.alacritty = {
			enable = true;
			settings = {
				font = {
					normal.family = "JetBrainsMono Nerd Font";
					size = 13;
				};
				window = {
					padding = { x = 8; y = 8; };
					opacity = 0.95;
					decorations = "None";
				};
				cursor.style = "Beam";
			};
		};
	};
}
