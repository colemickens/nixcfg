{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizero1";
in
{
  imports = [
    ../rpi-bcm2835.nix
    "${modulesPath}/installer/sd-card/sd-image.nix"

    ../../profiles/user.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";

    environment.systemPackages = with pkgs; [
      picocom
      keyboard-layouts
    ];

    boot = {
      # TODO: it might be -just- libcomposite now, no g_hid?
      initrd.availableKernelModules = [ "dwc2" "libcomposite" ];
      kernelModules = [ "dwc2" "libcomposite" ];
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      loader.raspberryPi.version = 0;
      loader.raspberryPi.firmwareConfig =  ''
        dtoverlay=dwc2
      '';
    };
  };
}
