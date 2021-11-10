{ pkgs, ... }:

{
  config = {
    nixpkgs.config = {
      allowUnfree = true;
      #oraclejdk.accept_license = true;
    };

    users.users.unifi.group = "unifi";
    users.groups.unifi = {};

    services.unifi = {
      enable = true;
      unifiPackage = pkgs.unifiStable;
      #mongodbPackage = pkgs.mongodb;
      # defaults to regular `pkgs.jre8` ?
      # jrePackage = pkgs.jre8_headless;
      maximumJavaHeapSize = 256;
    };

    # systemd.services.unifi.wantedBy = pkgs.lib.mkForce [];

    networking.firewall.allowedTCPPorts = [ 8080 8443 ];
  };
}
