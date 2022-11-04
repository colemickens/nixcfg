{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  pixel3_ip4 = "100.83.93.42";
  pixel3_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6253:5d2a]";

  carbon_ip4 = "100.122.12.36";
  carbon_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:627a:c24]";
  # slynux_ip4 = "100.120.15.79";
  # slynux_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6278:f4f]";
  slynux_ip4 = "192.168.30.181";
  # slynux_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6278:f4f]";
  xeep_ip4 = "100.72.11.62";
  xeep_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6248:b3e]";
  raisin_ip4 = "100.112.194.64";
  raisin_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6270:c240]";
  jeffhyper_ip4 = "100.103.91.27";
  jeffhyper_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:6267:5b1b]";

  rpifour1_ip4 = "100.111.5.113";
  rpifour1_ip6 = "[fd7a:115c:a1e0:ab12:4843:cd96:626f:571]";
  
  internalDomain = "cleo.cat";

  template = pkgs.writeText "template.html" ''
    <html>
      <head><title>cleo cat!</title></head>
      <body>
        <h1>Ens encanta la Cleo!</h1>

        <h2>serveis</h2>
        <ul>
          <li><a href="https://x.${internalDomain}">deixa'm entrar</a></li>
        </ul>

        <h2>serveis2</h2>
        <ul>
          <li><a href="https://sd.${internalDomain}">stable-diffusion webui</a></li>
          <li><a href="https://sdo.${internalDomain}">stable-diffusion outputs</a></li>
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
        
        <h2>public serveis</h2>
        <ul>
          <li><a href="https://homie-cast.${internalDomain}">homie-cast</a></li>
        </ul>
        
        <h2>serveis</h2>
        <ul>
          <li><a href="http://sd.x.${internalDomain}">stable-diffusion</a></li>
        </ul>
        <ul>
          <li><a href="https://home.x.${internalDomain}">home-assistant</a></li>
          <li><a href="https://unifi.x.${internalDomain}">unifi</a></li>
          <li><a href="https://denon.x.${internalDomain}">denon</a></li>
          <li><a href="https://rtsptoweb.x.${internalDomain}">rtsptoweb</a></li>
          <li><a href="https://paperless.x.${internalDomain}">paperless</a></li>
          <li><a href="https://wphone.x.${internalDomain}">wphone</a></li>
        </ul>
        <ul>
          <li><a href="https://syncthing-pixel3.x.${internalDomain}">syncthing (pixel3)</a></li>
          <br/>
          <li><a href="https://syncthing-carbon.x.${internalDomain}">syncthing (carbon)</a></li>
          <li><a href="https://syncthing-slynux.x.${internalDomain}">syncthing (slynux)</a></li>
          <li><a href="https://syncthing-raisin.x.${internalDomain}">syncthing (raisin)</a></li>
          <li><a href="https://syncthing-xeep.x.${internalDomain}">syncthing (xeep)</a></li>
          <li><a href="https://syncthing-jeffhyper.x.${internalDomain}">syncthing (jeffhyper)</a></li>
        </ul>

        <h2>serveis futurs</h2>
        <ul>
          <li><a href="https://aria.x.${internalDomain}">aria2c - webui</a></li>
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

  protectedVhost = {
    useACMEHost = "${internalDomain}";
    forceSSL = true;
    extraConfig = ''
      auth_basic "protected ${internalDomain} service";
      auth_basic_user_file /run/secrets/htpasswd;
    '';
  };

  internalVhost = {
    useACMEHost = "${internalDomain}";
    forceSSL = true;
    extraConfig = ''
      allow 100.0.0.0/8;
      allow fd7a:115c:a1e0:ab12:0000:0000:0000:0000/64;
      deny all;
    '';
  };

  redirSecret = pkgs.writeText "redir-tkn.conf" ''
    return 301 https://openvscode.x.${internalDomain}?tkn="";
  '';
in
{
  config = {
    sops.secrets."cloudflare-cleo-cat-creds" = {
      owner = "acme";
      group = "acme";
    };
    sops.secrets."htpasswd" = {
      owner = "nginx";
      group = "nginx";
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 8000 9443 ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "cole.mickens@gmail.com";
      certs."${internalDomain}" = {
        dnsProvider = "cloudflare";
        #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        credentialsFile = config.sops.secrets."cloudflare-cleo-cat-creds".path;
        extraDomainNames = [
          "*.${internalDomain}"
          "*.x.${internalDomain}"
        ];
      };
    };

    # q: why isn't this done for me?
    # answer: because when nginx owns the acme setup, it configures the
    # group owner on the cert to be nginx's group
    users.users.nginx.extraGroups = [ "acme" ];

    environment.etc."sdo-www".source = "/home/cole/code/stable-diffusion/outputs";
    services.nginx = {
      enable = true;

      #recommendedTLSSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts."${internalDomain}" = {
        root = payload;
        default = true;
        useACMEHost = "${internalDomain}";
        forceSSL = true;
      };
      # virtualHosts."oci.${internalDomain}" = {
      #   useACMEHost = "${internalDomain}";
      #   addSSL = true;
      #   forceSSL = false;
      #   locations."/" = {
      #     extraConfig = ''
      #       proxy_set_header Host $proxy_host;
      #     '';
      #     # TODO: make this a dynamic proxy for oracle cloud?
      #     proxyPass = "https://objectstorage.us-phoenix-1.oraclecloud.com/n/axobinpd5xwy/b/ocicole1_bucket/o/";
      #   };
      # };

      virtualHosts."netboot.${internalDomain}" = {
        useACMEHost = "${internalDomain}";
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

      # EXTERNAL, PROTECTED
      virtualHosts."sd.${internalDomain}" = protectedVhost // {
        locations."/" = {
          proxyPass = "http://${slynux_ip4}:7860/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."sdo.${internalDomain}" = protectedVhost // {
        locations."/" = {
          proxyPass = "http://${slynux_ip4}:7861/";
          proxyWebsockets = true;
        };
        # locations."/" = {
        #   # root = "/etc/sdo-www/";
        #   root = "/var/lib/stable-diffusion/outputs";
        #   extraConfig = ''
        #     disable_symlinks off;
        #     autoindex on;
        #   '';
        # };
      };


      # INTERNAL ONLY
      virtualHosts."x.${internalDomain}" = internalVhost // {
        root = payload_vpn;
      };
      virtualHosts."home.x.${internalDomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "http://localhost:8123/";
          proxyWebsockets = true;
        };
      };

      # <homie-cast>
      virtualHosts."homie-cast.${internalDomain}" = {
        useACMEHost = "${internalDomain}";
        addSSL = true;
        forceSSL = false;
        locations."/" = {
          # proxyPass = "http://${slynux_ip4}:80/";
          proxyPass = "http://localhost:8000/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."homie-cast-ws.${internalDomain}" = {
        useACMEHost = "${internalDomain}";
        addSSL = true;
        forceSSL = false;
        locations."/" = {
          # proxyPass = "http://${slynux_ip4}:9443/";
          proxyPass = "http://localhost:9443/";
          proxyWebsockets = true;
        };
      };
      # </homie-cast>

      virtualHosts."denon.x.${internalDomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "http://192.168.1.126:80/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."unifi.x.${internalDomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "https://localhost:8443/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."rtsptoweb.x.${internalDomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "http://localhost:8083/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."paperless.x.${internalDomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "http://localhost:28981/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."wphone.x.${internalDomain}" = internalVhost // {
        locations."/" = {
          root = "/srv/wphone/public";
          proxyWebsockets = true;
          extraConfig = ''
            autoindex on;
          '';
        };
      };


      virtualHosts."aria2.x.${internalDomain}" = internalVhost // {
        locations."/".proxyPass = "http://localhost:${toString config.services.aria2.rpcListenPort}";
        locations."/".proxyWebsockets = true;
      };


      # syncthing
      virtualHosts."syncthing-slynux.x.${internalDomain}" = internalVhost // {
        locations."/".proxyPass = "http://${slynux_ip4}:8384/";
        locations."/".proxyWebsockets = true;
        locations."/".extraConfig = ''
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
      virtualHosts."syncthing-carbon.x.${internalDomain}" = internalVhost // {
        locations."/".proxyPass = "http://${carbon_ip6}:8384/";
        locations."/".proxyWebsockets = true;
        locations."/".extraConfig = ''
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
      virtualHosts."syncthing-xeep.x.${internalDomain}" = internalVhost // {
        locations."/".proxyPass = "http://${xeep_ip6}:8384/";
        locations."/".proxyWebsockets = true;
      };
      virtualHosts."syncthing-raisin.x.${internalDomain}" = internalVhost // {
        locations."/".proxyPass = "http://${raisin_ip6}:8384/";
        locations."/".proxyWebsockets = true;
        locations."/".extraConfig = ''
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
      virtualHosts."syncthing-jeffhyper.x.${internalDomain}" = internalVhost // {
        locations."/".proxyPass = "http://${jeffhyper_ip4}:8384/";
        locations."/".proxyWebsockets = true;
      };
    };
  };
}
