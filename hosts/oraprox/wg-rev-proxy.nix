{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  template = pkgs.writeText "template.html" ''
    <html>
      <head><title>cleo cat!</title></head>
      <body>
        <a href="https://home.cleo.cat">home-assistant</a>
        <a href="https://unifi.cleo.cat">unifi</a>
        <br/>
        version: @systemLabel@
      </body>
    </html>
  '';

  payload = pkgs.substituteAll {
    name = "index.html";
    src = template;
    dir = "/";
    systemLabel = config.system.nixos.label;
  };
in
{
  config = {
    # only allow nginx access over tailscale for now
    networking.firewall."tailscale0" = {
      allowedTCPPorts = [ 80 443 ];
    };

    security.acme = {
      acceptTerms = true;
      email = "cole.mickens@gmail.com";
      certs."cleo.cat" = {
        dnsProvider = "rfc2136";
        server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        credentialsFile = config.sops."cleo-cat-certs-secret";
        extraDomainNames = [ "*.cleo.cat" ];
      };
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."default" = {
      root = payload;
      default = true;
    };

    services.nginx.recommendedProxySettings = true;
    services.nginx.virtualHosts."home.cleo.cat".locations."/" = {
      proxyPass = "http://xeep.ts.r10e.tech:8123/";
      proxyWebsockets = true;
    };
    services.nginx.virtualHosts."unifi.cleo.cat".locations."/" = {
      proxyPass = "https://xeep.ts.r10e.tech:8443/";
      proxyWebsockets = true;
    };
  };
}
