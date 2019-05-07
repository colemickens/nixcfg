{ config, lib, stdenv, pkgs, ... }:

let
  hostname = "vera";
{
  imports = [
    ../modules/mixin-sshd.nix
    ../modules/mixin-unifi.nix
    ../modules/mixin-loremipsum-media.nix

    ../modules/user-cole.nix
  ];

  config = {
    ## minimal
    environment.noXlibs = true;
    i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];
    documentation.enable = false;
    documentation.nixos.enable = false;

    system.stateVersion = "19.03";

    time.timeZone = "America/Los_Angeles";
    services.timesyncd.enable = true;
    services.resolved.enable = true;
    nixpkgs.config.allowUnfree = true;
    
    networking.hostId = "dead4ef4";
    networking.hostName = hostname;
    networking.firewall.enable = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}

