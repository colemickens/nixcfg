{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  cfgLimit = 10;
in
{
  config = {
    boot = {
      # low mem device
      tmpOnTmpfs = lib.mkDefault false;
      cleanTmpDir = lib.mkDefault true;
      loader = {
        grub.enable = lib.mkDefault false;
        systemd-boot.enable = false;
        generic-extlinux-compatible.enable = lib.mkDefault true;
        generic-extlinux-compatible.configurationLimit = lib.mkDefault cfgLimit;
      };
      # kernelPackages will default to latest from our `mixins/common.nix`
      # kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };

    environment.systemPackages = with pkgs; [
      libraspberrypi
    ];

    nix.nixPath = lib.mkDefault [ ];
    nix.gc.automatic = lib.mkDefault true;

    # minimal, even if we dupe across mixins/common.nix
    documentation.enable = lib.mkDefault false;
    documentation.doc.enable = lib.mkDefault false;
    documentation.info.enable = lib.mkDefault false;
    documentation.nixos.enable = lib.mkDefault false;
    
    system.disableInstallerTools = true;

    networking.firewall.enable = lib.mkDefault true;

    services.fwupd.enable = lib.mkForce false; # doesn't xcompile, don't remember the details

    hardware.enableRedistributableFirmware = lib.mkForce false;
    hardware.firmware = with pkgs; [
      # linux-firmware
      raspberrypiWirelessFirmware
    ];

    # specialisation = {
    #   "foundation" = {
    #     inheritParentConfig = true;
    #     configuration = {
    #       config.boot.kernelPackages = pkgs.linuxPackages_rpi4;
    #     };
    #   };
    # };
  };
}
