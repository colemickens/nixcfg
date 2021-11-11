{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/flood.nix
  ];
  config = {
    services.rtorrent = {
      enable = true;
      openFirewall = true;
    };
    services.flood = {
      enable = true;
    };
  };
}
