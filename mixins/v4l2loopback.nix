{ config, lib, pkgs, ... }:
with lib;

{
  boot.extraModulePackages = [
    config.boot.kernelPackages.v4l2loopback
    #pkgs.linuxPackages_latest.v4l2loopback
  ];

  environment.systemPackages = with pkgs; [
    v4l-utils
  ];
}
