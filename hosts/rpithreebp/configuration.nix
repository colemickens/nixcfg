{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpithreebp";
in
{
  imports = [
    ../rpizero1/rpicore.nix
    ./sd-image-armv7l-multiplatform.nix
  ];

  config = {
    nixpkgs.crossSystem = lib.systems.examples.armv7l-hf-multiplatform;
    boot = {
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      loader.raspberryPi.version = 3;
    };
    networking.hostName = hostname;
  };
}
