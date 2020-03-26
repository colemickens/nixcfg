{ pkgs, modulesPath, ... }:

let
  lib = pkgs.lib;
  eth = "eth0";
  wg = "wg1";
  wg_port = 51820;
  externalIP = "192.168.1.117";
  external_range = "192.168.1.0/24";
  internalIP = "192.168.2.1";
  internal_range = "192.168.2.0/24";
in {
  imports = [
    ../../modules/common.nix
    #    ../../modules/pkgs-common.nix
    ../../modules/profile-interactive.nix
    ../../modules/user-cole.nix
    #    ../../modules/profile-sway.nix
    ../../modules/profile-sway-minimal.nix

    ../../modules/mixin-unifi.nix
    ../../modules/mixin-sshd.nix
    ../../modules/mixin-srht-cronjobs.nix
    ../../modules/loremipsum-media/rclone-mnt.nix

    ../../modules/home-assistant
    ../../modules/hidden-gateway
    ../../modules/wireguard

    "${modulesPath}/installer/cd-dvd/sd-image-raspberrypi4-new.nix"
  ];

  config = {
    nix.nixPath = [
      "nixpkgs=/home/cole/code/nixpkgs"
      "nixos-config=/home/cole/code/nixcfg/machines/raspberry/default.nix"
    ];

    documentation.nixos.enable = false;

    networking.hostName = "raspberry";

    environment.systemPackages = with pkgs; [
      #neovim
      ripgrep
      tmux
      htop
      alsaTools
      alsaUtils
      pulsemixer
      git-crypt
      git
    ];

    ##############################
    networking = {
      wireless.enable = false;
      interfaces.eth0.ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 16;
      }];
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];
    };
    #hardware.opengl = {
    #  enable = true;
    #  setLdLibraryPath = true;
    #  package = pkgs.mesa_drivers;
    #};
    #hardware.deviceTree = {
    #  base = pkgs.device-tree_rpi;
    #  overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    #};

    #boot.loader.raspberryPi.firmwareConfig = ''
    #  gpu_mem=192
    #  disable_overscan=1
    #  hdmi_drive=2
    #  dtparam=audio=on
    #'';
    ##############################

    fileSystems = lib.mkForce {
      "/boot" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        # we NEED this mounted
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };
  };
}

