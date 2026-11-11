{ self, inputs, ... }: {
	flake.nixosModules.oneironautConfiguration = { pkgs, lib, ... }: {
		imports =
			[ 
			self.nixosModules.oneironautHardware
			self.nixosModules.niri
			self.nixosModules.zsh
			self.nixosModules.kmonad
			self.nixosModules.postgres
			self.nixosModules.tailscale
			self.nixosModules.sddm
			];

		boot.loader.systemd-boot.enable = true;
		boot.loader.systemd-boot.configurationLimit = 5;
		boot.kernelModules = [ "i915"  "snd_hda_intel" "snd_soc_skl"];
		boot.supportedFilesystems = [ "ntfs" "hfs+" "hfsplus"];
		boot.kernelParams = [ "i915.force_probe=7d55" ]; 
		boot.kernelPackages = pkgs.linuxPackages_6_18;
		boot.extraModprobeConfig = ''options snd-hda-intel model=dell-headset-multi'';

		nix.settings.experimental-features = ["nix-command" "flakes"];
		nixpkgs.config.allowUnfree = true;

		hardware.bluetooth.enable = true;
		hardware.bluetooth.powerOnBoot = true;
		hardware.enableAllFirmware = true;
		hardware.enableRedistributableFirmware = true; 
		hardware.ipu6.enable = true;
		hardware.ipu6.platform = "ipu6epmtl";

		services.udev.packages = [ pkgs.probe-rs-tools ];
		services.udev.extraRules = ''
		SUBSYSTEM=="hidraw", MODE="0666"
		SUBSYSTEM=="usb", MODE="0666", TAG+="uaccess"
		'';
		programs.kdeconnect.enable = true;

		time.timeZone = "Europe/Rome";
		
		services.pulseaudio.enable = false;
		programs.xwayland.enable = true;
		services.upower.enable = true;
		services.printing = {
			enable = true;
			drivers = with pkgs; [ brgenml1lpr brgenml1cupswrapper brlaser ];
		};
		services.avahi = {
			enable = true;
			nssmdns4 = true;
			openFirewall = true;
		};
		services.pipewire = {
			enable = true;
			alsa.enable = true;
			pulse.enable = true;
		};
		xdg.portal = {
			enable = true;
			wlr.enable = false;
			extraPortals = with pkgs; [ 
				xdg-desktop-portal-gtk 
				xdg-desktop-portal-gnome 
				xdg-desktop-portal-wlr 
				xdg-desktop-portal-hyprland
			];
			config.common = {};
		};
		
		programs.nix-ld.enable = true;
		programs.direnv = {
			enable = true;
			nix-direnv.enable = true;
		};


		# services.prometheus = {
		# 	enable = true;
		# 	extraFlags = ["--enable-feature=otlp-write-receiver"];
		# 	globalConfig.scrape_interval = "10s"; # "1m"
		# 		scrapeConfigs = [
		# 		{
		# 			job_name = "node";
		# 			static_configs = [{
		# 				targets = [ "localhost:${toString 14269}" ];
		# 			}];
		# 		}
		# 		];
		# };


		networking.hostName = "AQC-TS-03"; # Define your hostname.
		networking.networkmanager = {
			enable = true;  
			plugins = with pkgs; [
			  networkmanager-openvpn
			];
		};
		networking.firewall.interfaces."enp0s31f6".allowedUDPPortRanges = [
		{ from = 3956; to = 3956; }
		{ from = 39999; to = 50000; }
		];
		networking.firewall = {
			enable = true;
			allowedTCPPorts = [ 
				3333
				57621
				4840
				4855
				5900
				5050
				8000
				4222  # NATS client port
				8222  # NATS monitoring port (optional)

				5000
				5001
			];
			allowedUDPPorts = [
				5353
					4840
					4855
					5900
					5050

5000
				5001
			];
		};


	# programs.thunar.enable = true;
	services.gvfs.enable = true;      
	
		services.openssh.enable = true;
		services.tumbler.enable = true;

		services.nats = {
			enable = true;
			jetstream = true;
			port = 4222;
			settings = {
				host = "0.0.0.0";
				# host = "192.168.30.103";
				#host = "192.168.12.1";
				# port = "4222";
				max_payload = 16777216;
				http_port = 8222; 
			};
		};

		virtualisation.docker.enable = true;
		virtualisation.oci-containers.backend = "docker";
		virtualisation.oci-containers.containers.bitdefender = {
			image = "bdfbusiness/bitdefender-security-container:7.0";
			environmentFiles = [ "/etc/bitdefender/bsc.env" ];  # a string, not ./path
			volumes = [
				"/var/lib/bitdefender:/data"
				"/sys:/mnt/host-sys"
				"/proc:/mnt/host-proc"
				"/etc/os-release:/mnt/host-os-release"
				"/:/mnt/host"
			];
			extraOptions = [ "--privileged" "--pid=host" "--net=host"
				"-u" ":10000" "--stop-timeout=60" ];
		};
		systemd.tmpfiles.rules = [ "d /var/lib/bitdefender 0700 root root -" ];

		users.users.riccardo = {
			isNormalUser = true;
			initialPassword = "123";
			extraGroups = [ "wheel" "libvirtd" "audio" "networkmanager" "dialout" "usb" "docker" "plugdev" "adbusers"];
			packages = with pkgs; [
				xclip
					slint-lsp
					sof-firmware
					lldb
					gh
					gcc
					pciutils
					tree
					ripgrep
					usbutils
					docker
					git
			];
		};

		environment.pathsToLink = [ "share/thumbnailers" ];


		system.stateVersion = "25.11"; # Did you read the comment?


	};
					   }
