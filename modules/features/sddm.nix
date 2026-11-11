{ self, inputs, ... }: {
	# "Marginalia" login screen (modules/features/sddm-marginalia). The right half
	# shows whatever wallpaper noctalia has: its wallpaper_changed hook (see
	# noctalia.nix) copies it into /var/lib/greeter-wallpaper, which the greeter
	# (running as the sddm user, unable to read ~) can read.
	flake.nixosModules.sddm = { pkgs, ... }:
		let
			theme = pkgs.stdenvNoCC.mkDerivation {
				name = "sddm-theme-marginalia";
				src = ./sddm-marginalia;
				installPhase = ''
					dir=$out/share/sddm/themes/marginalia
					mkdir -p $dir
					cp -r . $dir
					cp ${../../wallpapers/wallpaper.jpg} $dir/fallback.jpg
				'';
			};
		in
	{
		services.xserver.enable = true;
		services.displayManager.sddm = {
			enable = true;
			package = pkgs.kdePackages.sddm;
			theme = "marginalia";
		};
		environment.systemPackages = [ theme ];

		# The greeter only sees system fonts.
		fonts.packages = [ pkgs.source-serif pkgs.inter ];

		systemd.tmpfiles.rules = [ "d /var/lib/greeter-wallpaper 0755 riccardo users -" ];
	};
}
