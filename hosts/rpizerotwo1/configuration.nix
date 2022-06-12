{ config, inputs, pkgs, lib, ... }:

let
  hn = "rpizerotwo1";
  mbr_disk_id = "99999021";
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
    fonts.fontconfig.enable = false; # python-black / noto emoji failures
    tow-boot.config.rpi = {
      arm_boost = true;
      hdmi_safe = true;
      hdmi_drive = 2;
      force_turbo = true;
      disable_fw_kms_setup = true;
      # disable_fw_kms_setup = false;
    };
    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages_5_19;
      blacklistedKernelModules = [ "snd_bcm2835" ];
    };
    nixcfg.common.defaultNetworking = false;
    networking.useDHCP = true;
  };
}
