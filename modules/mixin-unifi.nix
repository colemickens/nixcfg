{ pkgs, ... }:

{
  config = {
    nixpkgs.config = {
      allowUnfree = true;
      oraclejdk.accept_license = true;
    };

    services.unifi = {
      enable = true;
      unifiPackage = pkgs.unifiStable;

      jrePackage = pkgs.jre8_headless;
    };

    networking.firewall.allowedTCPPorts = [ 8080 8443 ];
  };
}
