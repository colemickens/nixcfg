{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  pixel3_ip4 = "100.83.93.42";
  pixel3_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6253:5d2a]";

  porty_ip4 = "100.112.137.125";
  porty_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6270:897d]";
  sinkor_ip4 = "100.88.111.30";
  sinkor_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6258:6f1e]";
  xeep_ip4 = "100.72.11.62";
  xeep_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6248:b3e]";
  raisin_ip4 = "100.92.252.95";
  raisin_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:625c:fc5f]";
  slywin_ip4 = "100.71.20.50";
  slywin_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6247:1432]";
  raiswin_ip4 = "100.84.178.79";
  raiswin_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6254:b24f]";
  pelinore_ip4 = "100.78.207.66";
  pelinore_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:624e:cf42]";
  jeffhyper_ip4 = "100.103.91.27";
  jeffhyper_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6267:5b1b]";

  rpifour1_ip4 = "100.111.5.113";
  rpifour1_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:626f:571]";

  template = pkgs.writeText "template.html" ''
    <html>
      <head><title>cleo cat!</title></head>
      <body>
        <h1>Ens encanta la Cleo!</h1>

        <h2>serveis</h2>
        <ul>
          <li><a href="https://x.cleo.cat">deixa'm entrar</a></li>
        </ul>

        <br/>
        <pre>versió: @systemLabel@</pre>
      </body>
    </html>
  '';
  template_vpn = pkgs.writeText "template.html" ''
    <html>
      <head><title>cleo cat!</title></head>
      <body>
        <h1>Ens encanta la Cleo!</h1>

        <h2>serveis</h2>
        <ul>
          <li><a href="https://home.x.cleo.cat">home-assistant</a></li>
          <li><a href="https://homie.x.cleo.cat">homie (hodd)</a></li>
          <li><a href="https://unifi.x.cleo.cat">unifi</a></li>
          <li><a href="https://denon.x.cleo.cat">denon</a></li>
          <li><a href="https://code.x.cleo.cat">code-server</a></li>
          <li><a href="https://openvscode.x.cleo.cat">openvscode</a></li>
        </ul>
        <ul>
          <li><a href="https://syncthing-pixel3.x.cleo.cat">syncthing (pixel3)</a></li>
          <br/>
          <li><a href="https://syncthing-porty.x.cleo.cat">syncthing (porty)</a></li>
          <li><a href="https://syncthing-sinkor.x.cleo.cat">syncthing (sinkor)</a></li>
          <li><a href="https://syncthing-raisin.x.cleo.cat">syncthing (raisin)</a></li>
          <li><a href="https://syncthing-xeep.x.cleo.cat">syncthing (xeep)</a></li>
          <li><a href="https://syncthing-jeffhyper.x.cleo.cat">syncthing (jeffhyper)</a></li>
          <br/>
          <li><a href="https://syncthing-slywin.x.cleo.cat">syncthing (slywin)</a></li>
          <li><a href="https://syncthing-raiswin.x.cleo.cat">syncthing (raiswin)</a></li>
          <li><a href="https://syncthing-pelinore.x.cleo.cat">syncthing (pelinore)</a></li>
        </ul>

        <h2>serveis futurs</h2>
        <ul>
          <li><a href="https://aria.x.cleo.cat">aria2c - webui</a></li>
        </ul>

        <br/>
        <pre>versió: @systemLabel@</pre>
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

  redirSecret = pkgs.writeText "redir-tkn.conf" ''
    return 301 https://openvscode.x.cleo.cat?tkn="";
  '';
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

      #recommendedTLSSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts."cleo.cat" = {
        root = payload;
        default = true;
        useACMEHost = "cleo.cat";
        forceSSL = true;
      };
      virtualHosts."oci.cleo.cat" = {
        useACMEHost = "cleo.cat";
        addSSL = true;
        forceSSL = false;
        locations."/" = {
          extraConfig = ''
            proxy_set_header Host $proxy_host;
          '';
          # TODO: make this a dynamic proxy for oracle cloud?
          proxyPass = "https://objectstorage.us-phoenix-1.oraclecloud.com/n/axobinpd5xwy/b/ocicole1_bucket/o/";
        };
      };

      virtualHosts."netboot.cleo.cat" = {
        useACMEHost = "cleo.cat";
        addSSL = true;
        forceSSL = false;
        locations."/" = {
          root = pkgs.linkFarm "netboot" [
            #{ name = "x86_64"; path = (pkgs.linkFarm "netboot-x86_64" [
            #  { name = "generic"; path = inputs.self.nixosConfigurations.netboot-x86_64.config.system.build.netbootEnv; }
            #]);}
            #{ name = "aarch64"; path = (pkgs.linkFarm "netboot-aarch64" [
            #  { name = "generic"; path = inputs.self.nixosConfigurations.netboot-aarch64.config.system.build.netbootEnv; }
            #]);}
          ];

          extraConfig = ''
            disable_symlinks off;
            autoindex on;
          '';
        };
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
      virtualHosts."homie.x.cleo.cat" = {
        useACMEHost = "cleo.cat";
        addSSL = true;
        forceSSL = false;
        locations."/" = {
          root = pkgs.hodd;
          extraConfig = ''
            autoindex on;
          '';
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
      virtualHosts."code.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${porty_ip4}:4444";
        locations."/".proxyWebsockets = true;
      };

      # syncthing
      virtualHosts."syncthing-pixel3.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${pixel3_ip6}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-porty.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${porty_ip6}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-sinkor.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${sinkor_ip6}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-xeep.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${xeep_ip6}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-raisin.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${raisin_ip6}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-slywin.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${slywin_ip4}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-pelinore.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${pelinore_ip4}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-raiswin.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${raiswin_ip4}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-jeffhyper.x.cleo.cat" = internalVhost // {
        locations."/".proxyPass = "http://${jeffhyper_ip4}:8384/";
        locations."/".proxyWebsockets = true;
      };
    };
  };
}
