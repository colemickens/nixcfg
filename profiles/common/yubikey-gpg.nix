{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yubikey-personalization
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
}

