{ pkgs, ... }:

{
  services = {
    unifi = {
      unifiPackage = pkgs.unifiTesting;
      enable = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 8080 8443 ];
}

