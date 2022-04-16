{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpizero1";
in
{
  imports = [
    ./rpicore.nix
    ./sd-image-raspberrypi.nix
  ];

  config = {
    nixpkgs.crossSystem = lib.mkForce lib.systems.examples.raspberryPi;

    environment.systemPackages = with pkgs; [
      keyboard-layouts
    ];

    boot = {
      #kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi0;

      # TODO: it might be -just- libcomposite now, no g_hid?
      initrd.availableKernelModules = [ "dwc2" "libcomposite" ];
      kernelModules = [ "dwc2" "libcomposite" ];
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      loader.raspberryPi.version = 0;
      loader.raspberryPi.firmwareConfig =  ''
        dtoverlay=dwc2
      '';
    };
    networking.hostName = hostname;
  };
}
