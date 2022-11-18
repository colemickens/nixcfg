{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

{
  imports = [
    ./rpi-bcm2711.nix

    ../mixins/netboot-client.nix
    # ../rpi-sdcard.nix

    ../profiles/viz
    ../mixins/gfx-rpi.nix
    ../mixins/wpa-full.nix
  ];

  config = {
    fonts.fontconfig.enable = false; # python-black / noto emoji failures

    nixcfg.common.useZfs = false;

    tow-boot.autoUpdate = lib.mkDefault false; # default incase we're netbooting, sdcard profile overrides this
    tow-boot.config = {
      Tow-Boot.rpi-eeprom = {
        enable = true;
        extraConfig = ''
          BOOT_UART=1
          ENABLE_SELF_UPDATE=1
          BOOT_ORDER=0xf412 # netboot -> sdcard -> usbmsd -> reboot
        '';
      };
      Tow-Boot.rpi = {
        upstream_kernel = true;

        hdmi_safe = true;
        hdmi_drive = 2;
        disable_fw_kms_setup = true;

        arm_boost = true;
        initial_boost = 60;
        # hdmi_enable_4kp60 = true;
        hdmi_ignore_cec = true;

        enable_watchdog = true;
      };
    };

    boot.blacklistedKernelModules = [ "snd_bcm2835" ];

    nixcfg.common.defaultNetworking = false;
    # all our networking is defined in netboot client
    # ... for now (?)
  };
}

