{ config, pkgs, lib, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "plexmediaserver" ];
    networking.firewall.allowedTCPPorts = [ 32400 ];
    services = {
      plex = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
