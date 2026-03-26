{ self, inputs, ... }: {
	flake.nixosModules.gaming = { pkgs, lib, ... }: {
		# AMD driver
		boot.initrd.kernelModules = [ "amdgpu" ];
		services.xserver.videoDrivers = [ "amdgpu" ];

		# graphics / vulkan
		hardware.graphics = {
			enable = true;
			enable32Bit = true;       # required for steam 32bit games
				extraPackages = with pkgs; [
				mesa
					vulkan-tools
					vulkan-loader
					rocmPackages.clr       # OpenCL support
				];
		};

		# force RADV (mesa) over AMDVLK for better performance
		environment.sessionVariables = {
			AMD_VULKAN_ICD = "RADV";
		};

		# steam
		programs.steam = {
			enable = true;
			remotePlay.openFirewall = true;
			dedicatedServer.openFirewall = false;
		};

		programs.gamescope = {
			enable = true;
			capSysNice = true;
		};

		# lact for GPU monitoring/tuning
		services.lact.enable = true;
	};
					   }
