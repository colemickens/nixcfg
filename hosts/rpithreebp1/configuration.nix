{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpithreebp1";
  mbr_disk_id = "999993b1";

  _inst = target: pkgs.callPackage ../rpi-inst.nix {
    inherit pkgs inputs target;
    inherit (inputs) tow-boot;
    tconfig = inputs.self.nixosConfigurations.${target}.config;
  };
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

    environment.systemPackages = [
      (_inst "rpifour1")
      # (_inst "rpizerotwo1")
      # (_inst "rpizerotwo2")
      # (_inst "rpizerotwo3")
    ];

    nixcfg.common.defaultNetworking = false;
  };
}
