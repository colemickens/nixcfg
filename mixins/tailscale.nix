{ pkgs, config, ... }:

{
  imports = [
    ../modules/tailscale-autoconnect.nix
  ];

  config = {
    services.tailscale.enable = true;
    services.tailscale-autoconnect.enable = true;
    services.tailscale-autoconnect.tokenFile = "# use sops";
  };
}
