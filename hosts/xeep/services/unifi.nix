{ pkgs, ... }:

{
  config = {
    nixpkgs.config = {
      #allowUnfree = true;
      #oraclejdk.accept_license = true;
    };

    users.users.unifi.group = "unifi";
    users.groups.unifi = {};

    services.unifi = {
      enable = true;
      unifiPackage = pkgs.unifiStable;
      jrePackage = pkgs.jdk8_headless;
      maximumJavaHeapSize = 256;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts =
      [ 8080 8443 ];

    networking.firewall.interfaces."eth0".allowedTCPPorts =
      [ 8080 ];
  };
}
