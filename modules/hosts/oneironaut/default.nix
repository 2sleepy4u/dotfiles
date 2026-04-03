{ self, inputs, ... }: {
	imports = [
		inputs.home-manager.flakeModules.home-manager
	];
	flake.nixosConfigurations.oneironaut = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.oneironautConfiguration
				inputs.home-manager.nixosModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.riccardo = self.homeModules.riccardo;
				}
		];
	};
}
