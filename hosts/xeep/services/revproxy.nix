{
  config,
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:

let
  carbon_ip4 = "100.122.12.36";
  slynux_ip4 = "100.120.15.79";
  xeep_ip4 = "100.72.11.62";
  raisin_ip4 = "100.112.194.64";
  jeffhyper_ip4 = "100.103.91.27";

  domain = "cleo.cat";
  idomain = "x.cleo.cat";
  localCidr4 = "100.0.0.0/8";
  localCidr6 = "fd7a:115c:a1e0:ab12:0000:0000:0000:0000/64";
  realCidr4 = "192.168.0.0/16";

  template = pkgs.writeText "template.html" ''
    <html>
      <head>
        <title>cleo cat!</title>
        <meta charset="UTF-8">
      </head>
      <body>
        <h1>Ens encanta la Cleo!</h1>

        <h2>serveis (internal)</h2>
        <ul>
          <li><a href="https://home.${domain}">home-assistant</a></li>
        </ul>

        <br/>
        <pre>versió: @systemLabel@</pre>
      </body>
    </html>
  '';
  template_vpn = pkgs.writeText "template.html" ''
    <html>
      <head>
        <title>cleo cat!</title>
        <meta charset="UTF-8">
      </head>
      <body>
        <h1>Ens encanta la Cleo!</h1>
        
        <h2>public serveis</h2>
        <ul>
          <li><a href="https://homie-cast.${domain}">homie-cast</a></li>
        </ul>
        
        <h2>serveis</h2>
        <ul>
          <li><a href="http://sd.${idomain}">stable-diffusion</a></li>
        </ul>
        <ul>
          <li><a href="https://home.${idomain}">home-assistant</a></li>
          <li><a href="https://unifi.${idomain}">unifi</a></li>
          <li><a href="https://denon.${idomain}">denon</a></li>
          <li><a href="https://rtsptoweb.${idomain}">rtsptoweb</a></li>
          <li><a href="https://paperless.${idomain}">paperless</a></li>
          <li><a href="https://wphone.${idomain}">wphone</a></li>
        </ul>

        <h2>serveis futurs</h2>
        <ul>
          <li><a href="https://aria.${idomain}">aria2c - webui</a></li>
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
    useACMEHost = "${domain}";
    forceSSL = true;
    extraConfig = ''
      auth_basic "protected ${domain} service";
      auth_basic_user_file /run/secrets/htpasswd;
    '';
  };

  localVhost = {
    useACMEHost = "${domain}";
    forceSSL = true;
    extraConfig = ''
      allow ${localCidr4};
      allow ${realCidr4};
      deny all;
    '';
  };

  internalVhost = {
    useACMEHost = "${domain}";
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
    sops.secrets."htpasswd" = {
      owner = "nginx";
      group = "nginx";
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
        8000
        9443
      ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "cole.mickens@gmail.com";
      certs."${domain}" = {
        dnsProvider = "cloudflare";
        #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        credentialsFile = config.sops.secrets."cloudflare-cleo-cat-creds".path;
        extraDomainNames = [
          "*.${domain}"
          "*.${idomain}"
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

      virtualHosts."${domain}" = {
        root = payload;
        default = true;
        useACMEHost = "${domain}";
        forceSSL = true;
      };
      # virtualHosts."oci.${domain}" = {
      #   useACMEHost = "${domain}";
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

      virtualHosts."netboot.${domain}" = {
        useACMEHost = "${domain}";
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

      # "EXTERNAL", UNPROTECTED, LIMITED TO LOCAL
      virtualHosts."home.${domain}" = localVhost // {
        locations."/" = {
          proxyPass = "http://localhost:8123/";
          proxyWebsockets = true;
        };
      };

      # EXTERNAL, PROTECTED
      virtualHosts."sd.${domain}" = protectedVhost // {
        locations."/" = {
          proxyPass = "http://${slynux_ip4}:7860/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."sdo.${domain}" = protectedVhost // {
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
      virtualHosts."${idomain}" = internalVhost // {
        root = payload_vpn;
      };
      virtualHosts."home.${idomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "http://localhost:8123/";
          proxyWebsockets = true;
        };
      };

      # # <homie-cast>
      # virtualHosts."homie-cast.${domain}" = {
      #   useACMEHost = "${domain}";
      #   addSSL = true;
      #   forceSSL = false;
      #   locations."/" = {
      #     # proxyPass = "http://${slynux_ip4}:80/";
      #     proxyPass = "http://localhost:8000/";
      #     proxyWebsockets = true;
      #   };
      # };
      # virtualHosts."homie-cast-ws.${domain}" = {
      #   useACMEHost = "${domain}";
      #   addSSL = true;
      #   forceSSL = false;
      #   locations."/" = {
      #     # proxyPass = "http://${slynux_ip4}:9443/";
      #     proxyPass = "http://localhost:9443/";
      #     proxyWebsockets = true;
      #   };
      # };
      # # </homie-cast>

      virtualHosts."denon.${idomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "http://192.168.1.126:80/";
          proxyWebsockets = true;
        };
      };
      virtualHosts."unifi.${idomain}" = internalVhost // {
        locations."/" = {
          proxyPass = "https://localhost:8443/";
          proxyWebsockets = true;
        };
      };
    };
  };
}
