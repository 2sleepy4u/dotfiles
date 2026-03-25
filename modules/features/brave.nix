{ self, inputs, ...}: {
	flake.nixosModules.brave = { pkgs, ... }: {
		programs.chromium = {
			enable = true;
			extensions = [
				"cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
				"nngceckbapebfimnlniiiahkandclblb" # Bitwarden
			];

			extraOpts = {
				"CommandLineArgs" = [
					"--enable-features=UseOzonePlatform"
						"--ozone-platform-hint=wayland"
				];
			};
		};
	};
	flake.homeModules.brave = { pkgs, ... }: {
		programs.brave.enable = true;
		programs.brave.extensions = [
			{ id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
			{ id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
		];
		programs.brave.commandLineArgs = ["--enable-features=UseOzonePlatform"  "--ozone-platform-hint=wayland "];

	};
}
