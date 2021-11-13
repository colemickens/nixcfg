{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  template = pkgs.writeText "template.html" ''
    <html>
      <head><title>cleo cat!</title></head>
      <body>
        <ul>
          <li><a href="https://x.cleo.cat">let me in</a></li>
        </ul>
        <br/><br/><pre>version: @systemLabel@</pre>
      </body>
    </html>
  '';
  template_vpn = pkgs.writeText "template.html" ''
    <html>
      <head><title>cleo cat!</title></head>
      <body>
        <ul>
          <li><a href="https://home.x.cleo.cat">home-assistant</a></li>
          <li><a href="https://home2.x.cleo.cat">home-assistant (sdcard, HA OS)</a></li>
          <li><a href="https://flood.x.cleo.cat">flood</a></li>
          <li><a href="https://unifi.x.cleo.cat">unifi</a></li>
          <li><a href="https://denon.x.cleo.cat">denon</a></li>
          <li><a href="https://code.x.cleo.cat">code-server</a></li>
          <li><a href="https://openvscode.x.cleo.cat">openvscode</a></li>
        </ul>
        <br/><br/><pre>version: @systemLabel@</pre>
      </body>
    </html>
  '';

  payload = pkgs.substituteAll {
    name = "index.html";
    src = template;
    dir = "/";
    systemLabel = config.system.nixos.label;
  };
  payload_vpn = pkgs.substituteAll {
    name = "index.html";
    src = template_vpn;
    dir = "/";
    systemLabel = config.system.nixos.label;
  };

  internalVhost = {
    useACMEHost = "cleo.cat";
    forceSSL = true;
    extraConfig = ''
      allow 100.0.0.0/8;
      allow fd7a:115c:a1e0:ab12:0000:0000:0000:0000/64;
      deny all;
    '';
  };
in
{
  config = {
    sops.secrets."cloudflare-cleo-cat-creds" = {
      owner = "acme";
      group = "acme";
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
    };

    security.acme = {
      acceptTerms = true;
      email = "cole.mickens@gmail.com";
      certs."cleo.cat" = {
        dnsProvider = "cloudflare";
        #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        credentialsFile = config.sops.secrets."cloudflare-cleo-cat-creds".path;
        extraDomainNames = [
          "*.cleo.cat"
          "*.x.cleo.cat"
        ];
      };
    };

    # q: why isn't this done for me?
    # answer: because when nginx owns the acme setup, it configures the
    # group owner on the cert to be nginx's group
    users.users.nginx.extraGroups = ["acme"];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;

      virtualHosts."cleo.cat" = {
        root = payload;
        default = true;
        useACMEHost = "cleo.cat";
        forceSSL = true;
      };
      virtualHosts."x.cleo.cat" = internalVhost // {
        root = payload_vpn;
      };
      virtualHosts."home.x.cleo.cat" = internalVhost // {
        locations."/" = {
          proxyPass = "http://localhost:8123/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."home2.x.cleo.cat" = internalVhost // {
        locations."/" = {
          proxyPass = "http://192.168.162.88:8123/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."unifi.x.cleo.cat" = internalVhost // {
        locations."/" = {
          proxyPass = "https://localhost:8443/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."denon.x.cleo.cat" = internalVhost // {
        locations."/" = {
          proxyPass = "http://192.168.1.126:80/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."flood.x.cleo.cat" = internalVhost // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."code.x.cleo.cat" = internalVhost // {
        locations."/" = {
          proxyPass = "http://100.93.180.71:5902/"; # porty
          #proxyPass = "http://100.72.11.62:5902/"; # xeep
          #proxyPass = "http://localhost:5902/"; # self (xeep)
          proxyWebsockets = true;
        };
      };
      virtualHosts."openvscode.x.cleo.cat" = internalVhost // {
        locations."/" = {
          proxyPass = "http://100.93.180.71:5904/"; # porty
          #proxyPass = "http://100.72.11.62:5904/"; # xeep
          #proxyPass = "http://localhost:5904/"; # self (xeep)
          proxyWebsockets = true;
        };
      };
    };
  };
}
