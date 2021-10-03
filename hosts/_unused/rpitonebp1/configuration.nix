{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpionebp";
in
{
  imports = [
    ../rpizero1/rpicore.nix
    ../rpizero1/sd-image-raspberrypi.nix
  ];

  config = {
    boot = {
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      loader.raspberryPi.version = lib.mkForce 1;
    };

    networking.hostName = hostname;
  };
}
