{ self, inputs, ... }: {
	flake.homeModules.tmux = { pkgs, lib, ... }: {
		programs.fuzzel = {
			enable = true;
		};
	};
}
