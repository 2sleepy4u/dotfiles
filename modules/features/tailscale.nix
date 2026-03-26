{ self, inputs, ... }: {
  flake.nixosModules.tailscale = { pkgs, lib, ... }: {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };
}
