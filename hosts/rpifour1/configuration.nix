{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  hn = "rpifour1";

  pi_serial = "e43b854b";
  pi_mac = "dc-a6-32-47-73-14";
  pi_ubootid = "01-${pi_mac}";
  mbr_disk_id = "99999941";

  net_prefix = 16;
  eth_ip = "192.168.100.041";
  wifi_ip = "192.168.101.041";
in
{
  imports = [
    ../rpi-bcm2711.nix
    ../rpi-foundation-v3d.nix

    ../../mixins/netboot-client.nix
    # ../rpi-sdcard.nix

    ../../profiles/viz
    ../../mixins/gfx-rpi.nix
    ../../mixins/wpa-slim.nix
    # ../../mixins/wpa-full.nix
  ];

  config = {
    networking.hostName = lib.mkForce hn;
    system.stateVersion = "21.11";
    system.build = rec {
      inherit pi_serial pi_mac pi_ubootid mbr_disk_id;
      # extras = {
      #   sdcard = extendModules {
      #     imports = [ ../rpi-sdcard.nix ];
      #   };
      # };
    };
    
    fonts.fontconfig.enable = false; # python-black / noto emoji failures

    nixcfg.common.useZfs = false;

    tow-boot.config.rpi-eeprom = {
      enable = true;
      extraConfig = ''
        BOOT_UART=1
        ENABLE_SELF_UPDATE=1
        BOOT_ORDER=0xf412 # netboot -> sdcard -> usbmsd -> reboot
      '';
    };
    tow-boot.config.rpi = {
      upstream_kernel = false;
      disable_fw_kms_setup = false;

      arm_boost = true;
      initial_boost = 60;
      # hdmi_enable_4kp60 = true;
      hdmi_ignore_cec = true;

      enable_watchdog = true;
    };

    boot.kernelPackages = pkgs.linuxPackages_rpi4;
    boot.blacklistedKernelModules = [ "snd_bcm2835" ];

    nixcfg.common.defaultNetworking = false;
    networking.enableIPv6 = true;
    networking.interfaces."eth0".ipv4.addresses = [{
      address = eth_ip;
      prefixLength = net_prefix;
    }];
    networking.interfaces."wlan0".ipv4.addresses = [{
      address = wifi_ip;
      prefixLength = net_prefix;
    }];

    # TODO: possibly use tmpfiles to implement a lil rfkill module
  };
}
