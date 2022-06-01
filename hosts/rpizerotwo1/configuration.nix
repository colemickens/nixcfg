{ pkgs, lib, modulesPath, inputs, config, ... }:

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
      # firmwarePackage = lib.mkForce (pkgs.raspberrypifw.override {
      #   verinfo = {
      #     version = "2022-05-19";
      #     rev = "b22546ac06cf2e88f10873d2158069fa65ed86a3";
      #     hash = "sha256-1y8QNs65yoC5ftWbR8E8SKjjsROCV85BrJzD+EMCvOM=";
      #   };
      # });
      # disable_fw_kms_setup = lib.mkForce false;
    };
    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages_5_17;
      blacklistedKernelModules = if (config.networking.hostName == hn) then [ "snd_bcm2835" ] else [];
    };

    hardware.enableRedistributableFirmware = true;
    nixcfg.common.defaultNetworking = false;
    networking.useDHCP = true;
  };
}
