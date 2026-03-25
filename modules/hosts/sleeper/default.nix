{ self, inputs, ... }: {
      imports = [
        # Import home-manager's flake module
	      inputs.home-manager.flakeModules.home-manager

      ];
	flake.nixosConfigurations.sleeper = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.sleeperConfiguration
				inputs.home-manager.nixosModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.im2sleepy = self.homeModules.im2sleepy;
				}
		];
	};
/*
	flake.homeConfigurations.im2sleepy = inputs.home-manager.lib.homeManagerConfiguration {
		pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
		modules = [ self.homeModules.im2sleepy ];
	};
*/

}
