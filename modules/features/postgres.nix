{ self, inputs, ...}: {
	flake.nixosModules.postgres = { pkgs, ... }: {
		imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
		services.postgresql.enable = true;
		services.flatpak = {
			enable = true;
			remotes = [
			{
				name = "flathub";
				location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
			}
			];
			packages = [
			{ appId = "org.pgadmin.pgadmin4"; origin = "flathub"; }
			];
		};
	};
}
