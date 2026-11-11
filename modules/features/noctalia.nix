{ ... }: {
	# noctalia v5 (C++ rewrite, TOML config); nixpkgs dropped the Quickshell-based
	# noctalia-shell (v4). Run as HM's systemd user service so it's restarted on
	# crash instead of being spawned by niri.
	flake.homeModules.noctalia = { config, pkgs, lib, ... }:
		let
			noctalia = config.programs.noctalia.package;
			builtinTemplates = "${noctalia}/share/noctalia/assets/templates";

			# Validate at build time. `noctalia config validate` only fails on syntax
			# errors and prints unknown keys / wrong types as WARN, so treat any
			# warning as a build failure (programs.noctalia.checkConfig doesn't).
			validated = name: file: pkgs.runCommand name { } ''
				log=$(${lib.getExe noctalia} config validate ${file} 2>&1) \
					|| { echo "$log"; exit 1; }
				echo "$log"
				if grep -q '^WARN' <<< "$log"; then exit 1; fi
				cp ${file} $out
			'';

			# Hands the current wallpaper to the SDDM theme (modules/features/sddm.nix),
			# keeping its file name: the greeter turns "Title — Author.jpg" into the caption.
			# wallpaper_changed runs once per output, hence the same-file check.
			greeterWallpaper = pkgs.writeShellApplication {
				name = "noctalia-greeter-wallpaper";
				runtimeInputs = [ pkgs.coreutils noctalia ];
				text = ''
					dest=/var/lib/greeter-wallpaper
					[ -w "$dest" ] || exit 0
					src=''${NOCTALIA_WALLPAPER_PATH:-$(noctalia msg wallpaper-get)}
					[ -f "$src" ] || exit 0
					target="$dest/$(basename "$src")"
					[ -e "$target" ] && cmp -s "$src" "$target" && exit 0
					find "$dest" -mindepth 1 -maxdepth 1 -type f -delete
					install -m644 "$src" "$target"
				'';
			};
		in
	{
		programs.noctalia = {
			enable = true;
			systemd.enable = true;
		};
		# HM tmux (secureSocket) puts servers in $XDG_RUNTIME_DIR via TMUX_TMPDIR, set
		# only in the login shell env; without it the tmux template hook looks in /tmp
		# and reloads nothing.
		systemd.user.services.noctalia.Service.Environment = [ "TMUX_TMPDIR=%t" ];

		xdg.configFile."noctalia/config.toml".source = validated "noctalia-config.toml" ./noctalia.toml;

		# noctalia merges every *.toml in its config dir; this one is generated so it
		# can point at store paths.
		xdg.configFile."noctalia/hooks.toml".source = validated "noctalia-hooks.toml"
			((pkgs.formats.toml { }).generate "hooks.toml" {
				hooks = {
					started = lib.getExe greeterWallpaper;
					wallpaper_changed = lib.getExe greeterWallpaper;
				};
			});

		# Theming: noctalia owns the palette and renders it through the templates
		# enabled in noctalia.toml [theme.templates]. Every app config below only
		# includes the rendered file, so changing the scheme in noctalia recolors
		# everything without a rebuild. The include lines match what the templates'
		# apply hooks look for, so the hooks never try to rewrite these read-only files.

		# User template `niri` in noctalia.toml (input path is relative to ~/.config/noctalia).
		xdg.configFile."noctalia/templates/niri.kdl".source = "${builtinTemplates}/niri/niri.kdl";

		# builtin `alacritty` → ~/.config/alacritty/themes/noctalia.toml (live_config_reload).
		programs.alacritty.settings.general.import = [ "~/.config/alacritty/themes/noctalia.toml" ];

		# user template `fuzzel` (community one, background made opaque)
		# → ~/.config/fuzzel/themes/noctalia
		xdg.configFile."noctalia/templates/fuzzel.conf".source = ./noctalia-fuzzel.conf;
		programs.fuzzel.settings.main.include = "${config.xdg.configHome}/fuzzel/themes/noctalia";
		# fuzzel doesn't read the GTK icon theme (defaults to hicolor).
		programs.fuzzel.settings.main.icon-theme = config.gtk.iconTheme.name;

		# community `tmux` → sourced on every running server by the hook. Must stay
		# the last line of tmux.conf, byte-identical to the one the hook appends
		# (plain string: '' strings don't strip tab indentation).
		programs.tmux.extraConfig = lib.mkAfter
			"source-file -q \"$HOME/.config/tmux/themes/noctalia.conf\"\n";

		# community `fzf` → shell snippet exporting FZF_DEFAULT_OPTS (new shells).
		programs.zsh.initContent = ''
			[ -f "$HOME/.config/fzf/themes/noctalia.sh" ] && source "$HOME/.config/fzf/themes/noctalia.sh"
		'';

		# user template `nvim` → ~/.config/nvim/lua/matugen.lua: feeds the palette to
		# catppuccin.nvim (from colorschemes.catppuccin in nixvim.nix, which stays the
		# fallback until the file is rendered) and reloads itself on SIGUSR1 (sent by
		# the template's post_hook). Runs after nixvim's own `colorscheme catppuccin`.
		xdg.configFile."noctalia/templates/nvim.lua".source = ./noctalia-nvim.lua;
		programs.nixvim = {
			extraConfigLuaPost = ''
				package.path = vim.fn.stdpath("config") .. "/lua/?.lua;" .. package.path
				local ok, matugen = pcall(require, 'matugen')
				if ok then pcall(matugen.setup) end
			'';
		};

		# builtin `gtk3`/`gtk4` → noctalia.css; community `thunar` is a gtk3 extension
		# loaded through it. The hook only switches adw-gtk3 / adw-gtk3-dark on mode change.
		gtk = {
			enable = true;
			theme = {
				name = "adw-gtk3-dark";
				package = pkgs.adw-gtk3;
			};
			# community `papirus-icons` recolors the folders to the palette's primary
			# (in a writable copy under ~/.local/share/icons).
			iconTheme = {
				name = "Papirus-Dark";
				package = pkgs.papirus-icon-theme;
			};
			gtk3.extraCss = ''@import url("noctalia.css");'';
			gtk4.extraCss = ''@import url("noctalia.css");'';
		};

		# builtin `qt` → qt5ct/qt6ct color scheme.
		qt = {
			enable = true;
			platformTheme.name = "qtct";
			style.name = "Fusion";
		};
		qt.qt5ctSettings.Appearance = {
			custom_palette = true;
			color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
			style = "Fusion";
		};
		qt.qt6ctSettings.Appearance = {
			custom_palette = true;
			color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
			style = "Fusion";
		};
	};
}
