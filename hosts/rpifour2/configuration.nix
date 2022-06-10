{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  hn = "rpifour2";

  pi_serial = "156b6214";
  pi_mac = "dc-a6-32-59-d6-f8";
  pi_ubootid = "01-${pi_mac}";
  mbr_disk_id = "99999942";

  net_prefix = 16;
  eth_ip = "192.168.100.042";
  wifi_ip = "192.168.101.042";
in
{
  imports = [
    ../rpi-bcm2711.nix

    ../../mixins/netboot-client.nix
    # ../rpi-sdcard.nix

    ../../profiles/viz
    ../../mixins/gfx-rpi.nix
    ../../mixins/wpa-full.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build = rec {
      inherit pi_serial pi_mac pi_ubootid mbr_disk_id;
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
      upstream_kernel = true;

      hdmi_safe = true;
      hdmi_drive = 2;
      disable_fw_kms_setup = true;
      mainlineKernel = lib.mkForce pkgs.linuxPackages_5_19.kernel;

      arm_boost = true;
      initial_boost = 60;
      # hdmi_enable_4kp60 = true;
      hdmi_ignore_cec = true;

      enable_watchdog = true;
    };

    boot.kernelPackages = lib.mkOverride 500 pkgs.linuxPackages_5_19;
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
  };
}
