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

    tow-boot.autoUpdate = lib.mkForce false;
    tow-boot.config = {
      rpi-eeprom = {
        enable = true;
        extraConfig = ''
          BOOT_UART=1
          ENABLE_SELF_UPDATE=1
          BOOT_ORDER=0xf412 # netboot -> sdcard -> usbmsd -> reboot
        '';
      };
      rpi = {
        upstream_kernel = true;

        hdmi_safe = true;
        hdmi_drive = 2;
        disable_fw_kms_setup = true;
        # mainlineKernel = lib.mkForce pkgs.linuxPackages_5_19.kernel;
        mainlineKernel = lib.mkForce pkgs.linuxPackages_latest.kernel;

        arm_boost = true;
        initial_boost = 60;
        # hdmi_enable_4kp60 = true;
        hdmi_ignore_cec = true;

        enable_watchdog = true;
      };
    };

    # <v3d>
    boot.kernelPackages = pkgs.linuxPackages_5_18;
    boot.kernelPatches = [
      {
        name = "v3d-enable-part1";
        patch = pkgs.fetchpatch {
          url = "https://patchwork.kernel.org/series/646576/mbox/";
          excludes = [ "Documentation/*" ];
          sha256 = "sha256-rn2+D2NjUTbfUtLb7uDBTzIpYIRo90p9SqxB1a2/XuY=";
        };
      }
      {
        name = "v3d-enable-part2";
        patch = pkgs.fetchpatch {
          url = "https://patchwork.kernel.org/series/647129/mbox/";
          excludes = [ "Documentation/*" ];
          sha256 = "sha256-+ohSoSvdTEqVCgWDIYy3Mq8aulDNYtnHaQ1K85y3e4k=";
        };
      }
      {
        name = "vc4-enable-cec";
        patch = null;
        extraConfig = ''
          DRM_VC4_HDMI_CEC y
        '';
      }
    ];
    # </v3d>
    boot.blacklistedKernelModules = [ "snd_bcm2835" ];

    nixcfg.common.defaultNetworking = false;
    # all our networking is defined in netboot client
    # ... for now (?)
  };
}

