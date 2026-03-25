{ self, inputs, ... }: {
  flake.homeModules.starship = { pkgs, lib, ... }: {
    programs.starship = {
      enable = true;
	  enableZshIntegration = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[❯](mauve)";
          error_symbol = "[❯](red)";
        };
        directory = {
          style = "blue";
          truncation_length = 3;
          truncate_to_repo = true;
        };
        git_branch.style = "green";
        git_status.style = "yellow";
      };
    };
  };
}
