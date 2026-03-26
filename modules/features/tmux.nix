{ self, inputs, ... }: {
	flake.homeModules.tmux = { pkgs, lib, ... }: {
		programs.tmux = {
			enable = true;
			keyMode = "vi";
			shortcut = "h";
			extraConfig = ''
				set -sg escape-time 0

				unbind & 
				bind -r k kill-window

				unbind c 
				bind -r Enter new-window

				unbind f
				bind -r f display-popup -E w 80% -h 80% -T "Open workspace" "f"
				'';
			baseIndex = 1;
			plugins = with pkgs.tmuxPlugins; [ 
				battery
				catppuccin
				resurrect
				yank
			];
		};

		programs.fzf = {
			enable = true;
			enableZshIntegration = true;
		};
	};
}
