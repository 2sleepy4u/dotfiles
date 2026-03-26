{ self, inputs, ... }: {
	flake.homeModules.mpv = { pkgs, lib, ... }: {
		home.packages = [ pkgs.yt-dlp ];

		programs.mpv = {
			enable = true;
			scripts = with pkgs.mpvScripts; [
				uosc          # modern UI overlay
				thumbfast      # thumbnail previews on seekbar
				sponsorblock   # skip sponsors on youtube
			];
			config = {
				volume = 50;
				ytdl-format = "bestvideo+bestaudio/best";
				ytdl = true;
				cache = "yes";
				profile = "high-quality";
				hwdec = "auto-safe";
				vo = "gpu-next";
				audio-stream-silence = true;
				keep-open = true;
			};
		};
	};
					   }
