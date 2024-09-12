{
  config,
  pkgs,
  lib,
  ...
}:

let
  allowedRules = {
    # https://help.ui.com/hc/en-us/articles/218506997-UniFi-Ports-Used
    allowedTCPPorts = [
      8080 # Port for UAP to inform controller.
      8880 # Port used for HTTP portal redirection.
      8843 # Port used for HTTPS portal redirection.
      8443 # Port used for application GUI/API as seen in a web browser.
      6789 # Port for UniFi mobile speed test.
    ];
    allowedUDPPorts = [
      3478 # UDP port used for STUN.
      1900 # Port used for "Make application discoverable on L2 network" in the UniFi Network settings.
      10001 # Port used for device discovery.
    ];
  };
  # allowedInterfaces = [
  #   "enp57s0u1u3" # sighx2.1
  # ];
in
{
  config = {
    users.users.unifi.group = "unifi";
    users.groups.unifi = { };

    services.unifi = {
      enable = true;
      openFirewall = false;
      unifiPackage = pkgs.unifi8;
      # jrePackage = pkgs.temurin-jre-bin;
      jrePackage = pkgs.temurin-bin-17;
      mongodbPackage = pkgs.mongodb-6_0;
      maximumJavaHeapSize = 256;
    };

    networking.firewall.allowedTCPPorts = allowedRules.allowedTCPPorts;
    networking.firewall.allowedUDPPorts = allowedRules.allowedUDPPorts;
    # networking.firewall.interfaces = lib.mkMerge [
    #   (lib.genAttrs allowedInterfaces (n: allowedRules))
    #   ({
    #     "tailscale0".allowedTCPPorts = [ 8080 8443 ];
    #   })
    # ];
  };
}
