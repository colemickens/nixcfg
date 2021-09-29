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
    nixpkgs.crossSystem = lib.systems.examples.raspberryPi;
    boot = {
      #kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi0;
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      loader.raspberryPi.version = 0;
    };
    networking.hostName = hostname;

    networking.wireless.networks."chimera-iot".pskRaw = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
  };
}
