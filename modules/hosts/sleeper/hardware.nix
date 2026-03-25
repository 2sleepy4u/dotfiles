{ self, inputs, ... }: {
	flake.nixosModules.sleeperHardware = { config, pkgs, lib, modulesPath, ... }: {
		imports =
			[ (modulesPath + "/installer/scan/not-detected.nix")
			];

		boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
		boot.initrd.kernelModules = [ ];
		boot.kernelModules = [ "kvm-intel" ];
		boot.extraModulePackages = [ ];

		fileSystems."/" =
		{ device = "/dev/disk/by-uuid/ee17e739-044f-4000-916a-1a1a6d687e7d";
			fsType = "ext4";
		};

		fileSystems."/boot" =
		{ device = "/dev/disk/by-uuid/F3C8-EA95";
			fsType = "vfat";
			options = [ "fmask=0077" "dmask=0077" ];
		};

		swapDevices = [ ];

		nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
		hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

	};
}
	
