{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizero1";
in
{
  imports = [
    ../rpi-bcm2835.nix
    "${modulesPath}/installer/sd-card/sd-image-raspberrypi.nix"

    ../../profiles/user.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
      
    nixcfg.common.useZfs = false;

    environment.systemPackages = with pkgs; [
      picocom
      keyboard-layouts
    ];

    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      supportedFilesystems = lib.mkForce [ "vfat" ]; # so we can include profiles/base without pulling in zfs
      # TODO: it might be -just- libcomposite now, no g_hid?
      initrd.availableKernelModules = [ "dwc2" "libcomposite" ];
      kernelModules = [ "dwc2" "libcomposite" ];
      loader.raspberryPi.version = 0;
      loader.raspberryPi.firmwareConfig =  ''
        dtoverlay=dwc2
      '';
    };
  };
}
