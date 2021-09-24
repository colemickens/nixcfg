{ pkgs, config, ... }:

{
  imports = [
    ../modules/tailscale-autoconnect.nix
  ];

  config = {
    services.tailscale.enable = true;
    services.tailscale-autoconnect.enable = false;
    services.tailscale-autoconnect.tokenFile = "# use sops";
  } // (if config.networking.hostName != "jeffhyper" then {} else {
    systemd.services.tailscale.serviceConfig.Environment = [
      "PORT=${config.services.tailscale.port}"
      "FLAGS=--exit-node=192.168.1.200"
    ];
  });
}
