{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpithreebp1";

  pi_serial = "abcdefab";
  pi_mac = "aa-aa-aa-aa-aa-aa";
  pi_ubootid = "01-${pi_mac}";
  mbr_disk_id = "999993b1";

  net_prefix = 16;
  eth_ip = "192.168.100.031";
  wifi_ip = "192.168.101.031";
in
{
  imports = [
    ../rpi-bcm2710a1.nix
    
    ../../mixins/netboot-client.nix    

    ../../profiles/viz
    ../../mixins/gfx-rpi.nix
    ../../mixins/wpa-full.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build = {
      inherit pi_serial pi_mac pi_ubootid mbr_disk_id;
    };

    fonts.fontconfig.enable = false; # python-black / noto emoji failures

    nixcfg.common.useZfs = false;

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
