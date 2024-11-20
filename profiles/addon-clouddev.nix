{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

# these are dev tools that we want available
# system wide on my dev machine(s)

{
  config = {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
      7777
      7778
    ];
    environment.systemPackages = [
      # (pkgs.writeShellScriptBin "start-openvscode-server" ''
      #   set -x
      #   port="$1"
      #   "${pkgs.openvscode-server}/bin/openvscode-server" --without-connection-token --accept-server-license-terms --host=0.0.0.0 --port=7777
      # '')
    ];
    services = {
      openvscode-server = {
        enable = true;
        user = "cole";
        group = "cole";
        host = "0.0.0.0"; # firewall protects us, we only allow in tailscale0
        withoutConnectionToken = true;
        telemetryLevel = "off";
        port = 7777;
        # extraEnvironment = {
        #   NIX_PATH = "nixpkgs=/home/cole/code/nixpkgs/cmpkgs";
        # };
      };
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    services.nginx.virtualHosts."ds-ws-colemickens.mickens.us" = {
        listen = [{port = 7778;  addr="0.0.0.0"; ssl = true;}];

        addSSL = true;
        enableACME = true;
        #root = "/var/www/ds-ws-colemickens.mickens.us";
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
    systemd.services."acme-ds-ws-colemickens.mickens.us" = {
      enable = false;
      wantedBy = lib.mkForce [ ];
    };
    # acme-ds-ws-colemickens.mickens.us.timer
    systemd.timers."acme-ds-ws-colemickens.mickens.us" = {
      enable = false;
      timerConfig = lib.mkForce {};
      wantedBy = lib.mkForce [];
    };
  };
}
