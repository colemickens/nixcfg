{ pkgs, ... }:

{
  services = {
    unifi = {
      unifiPackage = pkgs.unifiTesting;
      #jrePackage = pkgs.jre8_headless;
      enable = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 8080 8443 ];
}
