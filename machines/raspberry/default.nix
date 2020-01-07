{ pkgs, modulesPath, ... }:

let lib = pkgs.lib; in
{
  imports = [
    ../../modules/common.nix
    ../../modules/profile-interactive.nix

    ../../modules/mixin-unifi.nix
    ../../modules/mixin-plex-mpv.nix
    #../../modules/mixin-home-assistant.nix
    ../../modules/user-cole.nix
    "${modulesPath}/installer/cd-dvd/sd-image-raspberrypi4-new.nix"
  ];

  config = {
    services.openssh.enable = lib.mkForce true;
    nix.nixPath = [
      "nixpkgs=/home/cole/code/nixpkgs"
      "nixos-config=/home/cole/code/nixcfg/machines/raspberry/default.nix"
    ];

    networking.hostName = "raspberry";

    environment.systemPackages = with pkgs; [
      neovim
      ripgrep
      tmux htop
      plex-mpv-shim sway
      alsaTools alsaUtils pulsemixer
      git-crypt git
    ];

    ##############################
    networking.wireless.enable = false;
    hardware.opengl = {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };
    hardware.deviceTree = {
      base = pkgs.device-tree_rpi;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    };

    boot.loader.raspberryPi.firmwareConfig = ''
      gpu_mem=192
      disable_overscan=1
      hdmi_drive=2
      dtparam=audio=on
      #test
    '';
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
