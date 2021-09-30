{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpithreebp";
in
{
  imports = [
    ../rpizero1/rpicore.nix
    ./sd-image-aarch64.nix
  ];

  config = {
    nixpkgs.crossSystem = lib.systems.examples.aarch64-multiplatform;
    boot = {
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      loader.raspberryPi.version = lib.mkForce 3;
    };

    networking.hostName = hostname;
  };
}
