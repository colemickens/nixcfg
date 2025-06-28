{ hostname }:

{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  config = {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
      7777
      7778
    ];
    services = {
      openvscode-server = {
        enable = true;
        user = "cole";
        group = "cole";
        host = "0.0.0.0";
        withoutConnectionToken = true;
        telemetryLevel = "off";
        port = 7777;
      };
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    services.nginx.virtualHosts."${hostname}" = {
      listen = [
        {
          port = 7778;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];

      addSSL = true;
      enableACME = true;
      #root = "/var/www/${hostname}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:7777/";
        proxyWebsockets = true;
      };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "foo@bar.com";
      defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
    # block actually attempts to get cert, leaving us with whatever minica self-signed
    # note: seems like for the initial setup these need to be unmasked?
    systemd.services."acme-${hostname}" = {
      enable = false;
      wantedBy = lib.mkForce [ ];
    };
    # acme-${hostname}.timer
    systemd.timers."acme-${hostname}" = {
      enable = false;
      timerConfig = lib.mkForce { };
      wantedBy = lib.mkForce [ ];
    };
  };
}
