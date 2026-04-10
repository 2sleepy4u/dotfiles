{ self, inputs, ... }: {
	flake.nixosModules.sleeperConfiguration = { pkgs, lib, ... }: {
		imports =
			[ 
			self.nixosModules.sleeperHardware
			self.nixosModules.niri
			self.nixosModules.zsh
			self.nixosModules.gaming
			self.nixosModules.tailscale
			# self.nixosModules.stylix
			inputs.catppuccin.nixosModules.catppuccin
			];

		boot.initrd.kernelModules = [ "amdgpu" ];
		boot.loader.systemd-boot.enable = true;
		boot.loader.systemd-boot.configurationLimit = 4;
		boot.loader.efi.canTouchEfiVariables = true;
		boot.kernelPackages = pkgs.linuxPackages_latest;

		hardware.bluetooth.enable = true;
		hardware.bluetooth.powerOnBoot = true;

		nix.settings.experimental-features = ["nix-command" "flakes"];
		networking.hostName = "nixos"; 

		networking.networkmanager.enable = true;

		time.timeZone = "Europe/Rome";

		i18n.defaultLocale = "en_US.UTF-8";

		i18n.extraLocaleSettings = {
			LC_ADDRESS = "it_IT.UTF-8";
			LC_IDENTIFICATION = "it_IT.UTF-8";
			LC_MEASUREMENT = "it_IT.UTF-8";
			LC_MONETARY = "it_IT.UTF-8";
			LC_NAME = "it_IT.UTF-8";
			LC_NUMERIC = "it_IT.UTF-8";
			LC_PAPER = "it_IT.UTF-8";
			LC_TELEPHONE = "it_IT.UTF-8";
			LC_TIME = "it_IT.UTF-8";
		};

		services.xserver.xkb = {
			layout = "it";
			variant = "";
		};

		console.keyMap = "it2";

		users.users.im2sleepy = {
			isNormalUser = true;
			description = "2sleepy";
			extraGroups = [ "networkmanager" "wheel" ];
			packages = [ ];
		};

		# catppuccin.enable = true;
		services.displayManager.sddm = {
			enable = true;
			theme = "catppuccin-mocha-mauve";
			package = pkgs.kdePackages.sddm;

			wayland = {
				enable = true;

# default compositor is "weston", you can optionally change it to kwin
#compositor = "kwin";
			};
		};

		nixpkgs.config.allowUnfree = true;

		environment.systemPackages = with pkgs; [
  			vim 
			vulkan-tools
			pciutils
			lsof
			libsForQt5.qt5.qtquickcontrols2
			libsForQt5.qt5.qtgraphicaleffects
			xdg-desktop-portal-gtk
			
		];

		 services.openssh.enable = true;
		 services.printing.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
		system.stateVersion = "25.11"; # Did you read the comment?


	};
		       }
