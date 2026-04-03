{ self, inputs, ... }: {
	flake.nixosModules.oneironautHardware = { config, pkgs, lib, modulesPath, ... }: {
		imports =
			[ (modulesPath + "/installer/scan/not-detected.nix")
			];

		boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
		boot.initrd.kernelModules = [ ];
		boot.kernelModules = [ "kvm-intel" ];
		boot.extraModulePackages = [ ];

		fileSystems."/" =
		{ device = "/dev/disk/by-uuid/bf6df817-444c-4d42-9b58-e2a7d32fbed3";
			fsType = "btrfs";
			options = [ "subvol=root" ];
		};

		fileSystems."/home" =
		{ device = "/dev/disk/by-uuid/bf6df817-444c-4d42-9b58-e2a7d32fbed3";
			fsType = "btrfs";
			options = [ "subvol=home" ];
		};

		fileSystems."/nix" =
		{ device = "/dev/disk/by-uuid/bf6df817-444c-4d42-9b58-e2a7d32fbed3";
			fsType = "btrfs";
			options = [ "subvol=nix" ];
		};

		fileSystems."/boot" =
		{ device = "/dev/disk/by-uuid/A232-00D0";
			fsType = "vfat";
			options = [ "fmask=0022" "dmask=0022" ];
		};

		swapDevices = [ ];

		nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
		hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};
}

