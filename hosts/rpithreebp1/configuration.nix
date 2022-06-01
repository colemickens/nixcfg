{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpithreebp1";
  mbr_disk_id = "999993b1";

  _inst = d: import ../rpi-inst.nix {
    inherit pkgs;
    tconfig = inputs.self.nixosConfigurations.${d}.config;
  };
  
  rpipkgs = inputs.rpipkgs.legacyPackages.${pkgs.system};
in
{
  imports = [
    ../rpi-bcm2710a1.nix
    ../../profiles/viz
    ../../mixins/gfx-rpi.nix
    ../../mixins/wpa-full.nix
  ];

  config = {
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
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_17;
    boot.blacklistedKernelModules = [ "snd_bcm2835" ]; # ??

    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build.mbr_disk_id = mbr_disk_id;

    nixcfg.common.defaultNetworking = false;
    networking.useDHCP = true;
  };
}
