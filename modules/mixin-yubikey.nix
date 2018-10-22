{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
  ];

  services = {
    udev.packages = with pkgs; [
      yubikey-personalization
    ];
  };
}

