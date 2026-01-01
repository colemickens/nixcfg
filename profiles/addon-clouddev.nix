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
    sops.secrets."cloudflare_apitoken" = {
      owner = "nginx";
      group = "nginx";
      sopsFile = ../secrets/encrypted/cloudflare_apitoken;
      format = "binary";
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
      443
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

    services.nginx.virtualHosts."code.${hostname}" = {
      listen = [
        {
          port = 443;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];

      addSSL = true;
      useACMEHost = "${hostname}";
      #root = "/var/www/${hostname}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:7777/";
        proxyWebsockets = true;
      };
    };

    # VAULT WARDEN
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_PORT = "7077";
        DOMAIN = "https://vw.slynux.mickens.us";
      };
    };
    services.nginx.virtualHosts."vw.${hostname}" = {
      listen = [
        {
          port = 443;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];

      addSSL = true;
      useACMEHost = "${hostname}";
      #root = "/var/www/${hostname}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:7077/";
        proxyWebsockets = true;
      };
    };
    # END VAULT WARDEN

    security.acme = {
      acceptTerms = true;
      defaults = {
        #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        email = "cole.mickens@gmail.com";
        dnsProvider = "cloudflare";
        credentialFiles =
          let
            s = config.sops.secrets;
          in
          {
            CLOUDFLARE_DNS_API_TOKEN_FILE = s.cloudflare_apitoken.path;
            CLOUDFLARE_EMAIL_FILE = pkgs.writeText "cloudflare_email" "cole.mickens@gmail.com";
          };
        dnsResolver = "1.1.1.1:53";
      };
      certs."${hostname}" = {
        dnsPropagationCheck = true;
        domain = "${hostname}";
        extraDomainNames = [ "*.${hostname}" ];
        group = "nginx";
      };
    };
  };
}
