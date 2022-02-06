{ pkgs, ... }:

let
  allowedRules = {
      # https://help.ubnt.com/hc/en-us/articles/218506997
      allowedTCPPorts = [
        8080  # Port for UAP to inform controller.
        8880  # Port for HTTP portal redirect, if guest portal is enabled.
        8843  # Port for HTTPS portal redirect, ditto.
        6789  # Port for UniFi mobile speed test.
      ];
      allowedUDPPorts = [
        3478  # UDP port used for STUN.
        10001 # UDP port used for device discovery.
      ];
    };
in {
  config = {
    nixpkgs.config = {
      #allowUnfree = true;
      #oraclejdk.accept_license = true;
    };

    users.users.unifi.group = "unifi";
    users.groups.unifi = {};

    # environment.systemPackages = [
    #   pkgs.mongodb-3_6
    #   pkgs.mongodb-4_0
    # ];
    services.unifi = {
      enable = true;
      openFirewall = false;
      unifiPackage = pkgs.unifiStable;
      jrePackage = pkgs.jdk8_headless;
      mongodbPackage = pkgs.mongodb-3_4;
      maximumJavaHeapSize = 256;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts =
      [ 8080 8443 ];

    networking.firewall.interfaces."eth0" = allowedRules;
    networking.firewall.interfaces."enp57s0u1u3" = allowedRules;
  };
}
