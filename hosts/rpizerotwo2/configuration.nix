{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizerotwo2";
  mbr_disk_id = "99999022";
in
{
  imports = [
    ../rpi-bcm2710a1.nix
    ../../profiles/viz
    ../../mixins/gfx-rpi.nix
    ../../mixins/wpa-full.nix

    ../rpi-sdcard.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build.mbr_disk_id = mbr_disk_id;
    tow-boot.config.rpi = {
      arm_boost = true;
      hdmi_safe = true;
      hdmi_drive = 2;
      force_turbo = true;
    };
    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages_5_17;
      blacklistedKernelModules = [ "snd_bcm2835" ];
    };
    nixcfg.common.defaultNetworking = false;
    networking.useDHCP = true;
  };
}
