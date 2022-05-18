{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizerotwo1";
  mbr_disk_id = "99999021";
in
{
  imports = [
    ../rpi-bcm2710a1.nix
    ../../profiles/interactive.nix # common + interactive
    ../../mixins/pipewire.nix # snapcast
    ../../mixins/snapclient-local.nix # snapcast
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/wpa-slim.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build.mbr_disk_id = mbr_disk_id;

    nixcfg.common.defaultNetworking = false;
  };
}
