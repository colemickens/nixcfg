{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

{
  imports = [
    ./rpi-bcm2710a1.nix

    # IMPORTER PICKS ONE:
    # ../mixins/netboot-client.nix
    # ../rpi-sdcard.nix

    ../profiles/gui-viz.nix
    ../mixins/gfx-rpi.nix
  ];

  config = {
    fonts.fontconfig.enable = false; # python-black / noto emoji failures

    nixcfg.common.useZfs = false;

    tow-boot.autoUpdate = lib.mkDefault false; # default incase we're netbooting, sdcard profile overrides this
    tow-boot.config = {
      Tow-Boot.rpi = {
        upstream_kernel = true;

        hdmi_ignore_cec = lib.mkDefault true;
        hdmi_ignore_cec_init = lib.mkDefault true;
        hdmi_force_hotplug = true; # !! default: this comes from rpi-core, verbose tho
        hdmi_safe = true;
        hdmi_drive = 2;

        arm_boost = true;
        initial_boost = 60;
        force_turbo = true; # might help living room tv (but also breaks eth boot??)

        disable_fw_kms_setup = true;
        # firmwarePackage = lib.mkForce (pkgs.raspberrypifw.override {
        #   verinfo = {
        #     version = "2022-05-19";
        #     rev = "b22546ac06cf2e88f10873d2158069fa65ed86a3";
        #     hash = "sha256-1y8QNs65yoC5ftWbR8E8SKjjsROCV85BrJzD+EMCvOM=";
        #   };
        # });
      };
    };
    
    nixcfg.common.defaultKernel = false;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.blacklistedKernelModules = [ "snd_bcm2835" ];

    nixcfg.common.defaultNetworking = false;
    # all our networking is defined in netboot client
    # ... for now (?)
  };
}
