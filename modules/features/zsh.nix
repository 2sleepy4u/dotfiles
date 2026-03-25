{ self, inputs, ... }: {
	flake.nixosModules.zsh = { pkgs, lib, ... }: {
		programs.zsh.enable = true;
		users.users.im2sleepy.shell = pkgs.zsh;
	};
	flake.homeModules.zsh = { pkgs, lib, ... }: {
		programs.zsh = {
			enable = true;
			autosuggestion.enable = true;
			syntaxHighlighting.enable = true;
			enableCompletion = true;
		};
	};
}
