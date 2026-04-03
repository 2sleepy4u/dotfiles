{ self, inputs, ...}: {
	flake.nixosModules.kmonad = { pkgs, ... }: {
		services.kmonad = {
			enable = true;
			keyboards.myKeyboard = {
				device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";  # your actual device
					config = builtins.readFile ./neotokyoiii.kbd;
			};
		};
	};
}
