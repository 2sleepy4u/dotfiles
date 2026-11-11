{ self, inputs, config, ... }: {
	flake.nixosModules.niri = { pkgs, lib, ... }: {
		programs.niri = {
			enable = true;
			package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
		};
	};

	perSystem = { pkgs, lib, self', ... }: {
		packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
			inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
				settings = {
					# noctalia is started as a systemd user service (see
					# modules/features/noctalia.nix) so it gets auto-restarted
					# and cleaned up on crash, instead of spawned here.

					input.touch = {
						map-to-output = "HDMI-A-1";
					};

					window-rules = [
					{
						geometry-corner-radius = 12;
						clip-to-geometry = true;
					}
					{
						matches = [{ app-id = "^org.gnome.Calculator$"; }];
						open-floating = true;
						default-column-width = { fixed = 360; };
						default-window-height = { fixed = 616; };

					}
					{
						matches = [{ app-id = "^Thunar$"; }];
						open-floating = true;
						default-column-width = { fixed = 900; };
						default-window-height = { fixed = 600; };
					}
					{
						matches = [{ app-id = "^brave-browser$"; title = "^Picture in picture$"; }];
						open-floating = true;
						default-column-width = { fixed = 480; };
						default-window-height = { fixed = 270; };
					}
					{
						matches = [{ app-id = "^org.kde.kdeconnect.*"; }];
						open-floating = true;
						default-column-width = { fixed = 800; };
						default-window-height = { fixed = 600; };
					}
					];

					outputs =  {
						"eDP-1" = {
							mode = "1920x1080@120.030";
							scale = 1.5;
							transform = "normal";
							position =
								_: {
									props = { x = 1280; y = 0; };
								};
						};
						"DP-7" = {
							mode = "1920x1080@120.030";
							scale = 1.0;
							transform = "normal";
							position = _: {
								props = { x = 2240; y = 0; };
							};
						};
						"DP-5" = {
							mode = "1920x1080@120.030";
							scale = 1.0;
							transform = "normal";
							position = _: {
								props = { x = 4160; y = 0; };
							};
						};
					}; 

					xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

					input.keyboard.xkb.layout = "it";

					layout = {
						gaps = 10;
						border.off = {};
						# colors come from noctalia.kdl (included below)
						focus-ring.width = 1.5;
					};

					 prefer-no-csd = {};

					binds = {
						"Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
						"Mod+S".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle clipboard";


						"Mod+Space".spawn-sh = lib.getExe pkgs.fuzzel;
						"Mod+Q".close-window = {};
						# "Mod+S".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle launcher";

# Audio
						"XF86AudioRaiseVolume" = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; };
						"XF86AudioLowerVolume" = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; };
						"XF86AudioMute"        = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
						"XF86AudioMicMute"     = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; };
# Media (playerctl)
						"XF86AudioPlay" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl play-pause"; };
						"XF86AudioStop" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl stop"; };
						"XF86AudioPrev" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl previous"; };
						"XF86AudioNext" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl next"; };

# Brightness
						"XF86MonBrightnessUp"   = _: { props.allow-when-locked = true; content.spawn = [ (lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "+10%" ]; };
						"XF86MonBrightnessDown" = _: { props.allow-when-locked = true; content.spawn = [ (lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "10%-" ]; };

# Overview
						"Mod+O" = _: { props.repeat = false; content.toggle-overview = {}; };

# Focus
						"Mod+Left"  .focus-column-left  = {};
						"Mod+Down"  .focus-window-down  = {};
						"Mod+Up"    .focus-window-up    = {};
						"Mod+Right" .focus-column-right = {};
						"Mod+H"     .focus-column-left  = {};
						"Mod+J"     .focus-window-down  = {};
						"Mod+K"     .focus-window-up    = {};
						"Mod+L"     .focus-column-right = {};

# Move column/window
						"Mod+Ctrl+Left"  .move-column-left  = {};
						"Mod+Ctrl+Down"  .move-window-down  = {};
						"Mod+Ctrl+Up"    .move-window-up    = {};
						"Mod+Ctrl+Right" .move-column-right = {};
						"Mod+Ctrl+H"     .move-column-left  = {};
						"Mod+Ctrl+J"     .move-window-down  = {};
						"Mod+Ctrl+K"     .move-window-up    = {};
						"Mod+Ctrl+L"     .move-column-right = {};

# First / last
						"Mod+Home"      .focus-column-first  = {};
						"Mod+End"       .focus-column-last   = {};
						"Mod+Ctrl+Home" .move-column-to-first = {};
						"Mod+Ctrl+End"  .move-column-to-last  = {};

# Focus monitor
						"Mod+Shift+Left"  .focus-monitor-left  = {};
						"Mod+Shift+Down"  .focus-monitor-down  = {};
						"Mod+Shift+Up"    .focus-monitor-up    = {};
						"Mod+Shift+Right" .focus-monitor-right = {};
						"Mod+Shift+H"     .focus-monitor-left  = {};
						"Mod+Shift+J"     .focus-monitor-down  = {};
						"Mod+Shift+K"     .focus-monitor-up    = {};
						"Mod+Shift+L"     .focus-monitor-right = {};

# Move column to monitor
						"Mod+Shift+Ctrl+Left"  .move-column-to-monitor-left  = {};
						"Mod+Shift+Ctrl+Down"  .move-column-to-monitor-down  = {};
						"Mod+Shift+Ctrl+Up"    .move-column-to-monitor-up    = {};
						"Mod+Shift+Ctrl+Right" .move-column-to-monitor-right = {};
						"Mod+Shift+Ctrl+H"     .move-column-to-monitor-left  = {};
						"Mod+Shift+Ctrl+J"     .move-column-to-monitor-down  = {};
						"Mod+Shift+Ctrl+K"     .move-column-to-monitor-up    = {};
						"Mod+Shift+Ctrl+L"     .move-column-to-monitor-right = {};

# Workspace focus
						"Mod+Page_Down" .focus-workspace-down = {};
						"Mod+Page_Up"   .focus-workspace-up   = {};
						"Mod+U"         .focus-workspace-down  = {};
						"Mod+I"         .focus-workspace-up    = {};

# Move column to workspace
						"Mod+Ctrl+Page_Down" .move-column-to-workspace-down = {};
						"Mod+Ctrl+Page_Up"   .move-column-to-workspace-up   = {};
						"Mod+Ctrl+U"         .move-column-to-workspace-down = {};
						"Mod+Ctrl+I"         .move-column-to-workspace-up   = {};

# Move workspace itself
						"Mod+Shift+Page_Down" .move-workspace-down = {};
						"Mod+Shift+Page_Up"   .move-workspace-up   = {};
						"Mod+Shift+U"         .move-workspace-down = {};
						"Mod+Shift+I"         .move-workspace-up   = {};

# Mouse wheel workspace/column
						"Mod+WheelScrollDown"      = _: { props.cooldown-ms = 150; content.focus-workspace-down      = {}; };
						"Mod+WheelScrollUp"        = _: { props.cooldown-ms = 150; content.focus-workspace-up         = {}; };
						"Mod+Ctrl+WheelScrollDown" = _: { props.cooldown-ms = 150; content.move-column-to-workspace-down = {}; };
						"Mod+Ctrl+WheelScrollUp"   = _: { props.cooldown-ms = 150; content.move-column-to-workspace-up   = {}; };
						"Mod+WheelScrollRight"      .focus-column-right   = {};
						"Mod+WheelScrollLeft"       .focus-column-left    = {};
						"Mod+Ctrl+WheelScrollRight" .move-column-right    = {};
						"Mod+Ctrl+WheelScrollLeft"  .move-column-left     = {};
						"Mod+Shift+WheelScrollDown"      .focus-column-right = {};
						"Mod+Shift+WheelScrollUp"        .focus-column-left  = {};
						"Mod+Ctrl+Shift+WheelScrollDown" .move-column-right  = {};
						"Mod+Ctrl+Shift+WheelScrollUp"   .move-column-left   = {};

# Workspace by index
						"Mod+1" .focus-workspace = 1;
						"Mod+2" .focus-workspace = 2;
						"Mod+3" .focus-workspace = 3;
						"Mod+4" .focus-workspace = 4;
						"Mod+5" .focus-workspace = 5;
						"Mod+6" .focus-workspace = 6;
						"Mod+7" .focus-workspace = 7;
						"Mod+8" .focus-workspace = 8;
						"Mod+9" .focus-workspace = 9;

						"Mod+Ctrl+1" .move-column-to-workspace = 1;
						"Mod+Ctrl+2" .move-column-to-workspace = 2;
						"Mod+Ctrl+3" .move-column-to-workspace = 3;
						"Mod+Ctrl+4" .move-column-to-workspace = 4;
						"Mod+Ctrl+5" .move-column-to-workspace = 5;
						"Mod+Ctrl+6" .move-column-to-workspace = 6;
						"Mod+Ctrl+7" .move-column-to-workspace = 7;
						"Mod+Ctrl+8" .move-column-to-workspace = 8;
						"Mod+Ctrl+9" .move-column-to-workspace = 9;

# Consume / expel
						"Mod+BracketLeft"  .consume-or-expel-window-left  = {};
						"Mod+BracketRight" .consume-or-expel-window-right = {};
						"Mod+Comma"        .consume-window-into-column    = {};
						"Mod+Period"       .expel-window-from-column      = {};

# Resize
						"Mod+R"       .switch-preset-column-width  = {};
						"Mod+Shift+R" .switch-preset-window-height = {};
						"Mod+Ctrl+R"  .reset-window-height         = {};
						"Mod+Minus"   .set-column-width = "-10%";
						"Mod+Equal"   .set-column-width = "+10%";
						"Mod+Shift+Minus" .set-window-height = "-10%";
						"Mod+Shift+Equal" .set-window-height = "+10%";

# Layout
						"Mod+F"       .maximize-column                = {};
						"Mod+Shift+F" .fullscreen-window              = {};
						"Mod+Ctrl+F"  .expand-column-to-available-width = {};
						"Mod+C"       .center-column                  = {};
						"Mod+Ctrl+C"  .center-visible-columns         = {};

# Floating / tabbed
						"Mod+V"       .toggle-window-floating                   = {};
						"Mod+Shift+V" .switch-focus-between-floating-and-tiling = {};
						"Mod+W"       .toggle-column-tabbed-display             = {};

# Screenshot
						"Print"     .screenshot        = {};
						"Mod+P".screenshot-screen = {};
						"Mod+Alt+P" .screenshot-window = {};

# Misc
						"Mod+Escape" = _: { props.allow-inhibiting = false; content.toggle-keyboard-shortcuts-inhibit = {}; };
						"Mod+Shift+E"   .quit              = {};
						"Ctrl+Alt+Delete".quit             = {};
						"Mod+Shift+P"   .power-off-monitors = {};
						"Mod+Shift+T".spawn-sh = "${lib.getExe pkgs.noctalia} msg theme-mode-toggle";
					};
				};
				# Palette rendered by noctalia (user template `niri` in noctalia.toml);
				# niri hot-reloads included files. Must come after `settings` to override.
				extraSettings = [
					{ include = [ { optional = true; } "~/.config/niri/noctalia.kdl" ]; }
				];
		};
	};
}
