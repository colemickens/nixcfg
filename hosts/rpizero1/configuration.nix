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
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi0;
      loader.raspberryPi.version = 0;
    };
    networking.hostName = hostname;
  };
}
