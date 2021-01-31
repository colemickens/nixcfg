{ pkgs, modulesPath, inputs, config, ... }:
let
  hostname = "rpifour1";
in
{
  imports = [
    ./core.nix

    ./modules/home-assistant
    #./modules/wireguard

    ./modules/nginx.nix
    ./modules/postgres.nix

    ../../mixins/avahi-publish.nix
    ../../mixins/srht-cronjobs.nix
    ../../mixins/unifi.nix
  ];
}
