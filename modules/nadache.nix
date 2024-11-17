{
  config,
  pkgs,
  lib,
  ...
}:

let
  suffix = "nadache.r10e.dev"; # TODO: this moves out with options fixup
  cfg = config.services.nadache;

  # submap = lib.attrsets.mapAttrs' (n: v: {
  #   name = builtins.replaceStrings [ "-" ] [ "_" ] n;
  #   value = v;
  # };

  san = n: builtins.replaceStrings [ "-" ] [ "_" ] n;
in
{
  options.services.nadache = {
    enable = lib.mkEnableOption "nadache";

    port = lib.mkOption {
      type = lib.types.int;
      default = 9999;
    };

    cacheRoot = lib.mkOption {
      type = lib.types.str;
      default = "/var/www/nadache";
    };

    substituterMirrorMap = lib.mkOption {
      description = "adfasdF";
      type = lib.types.attrs;
      default = {
        "cache-nixos-org" = "cache.nixos.org";
        "colemickens-cachix-org" = "colemickens.cachix.org";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # systemd service
    # sytsemd timer
    # nginx to serve files?
    networking.firewall.allowedTCPPorts = [ cfg.port ]; # TODO This is supposed to be behind a firewall flag
    systemd.services.nginx = {
      serviceConfig = {
        ReadWritePaths = [ cfg.cacheRoot ];
      };
    };
    services.nginx = {
      enable = true;
      appendHttpConfig = ''
        proxy_cache_path ${cfg.cacheRoot}/cache levels=1:2 keys_zone=cachecache:100m max_size=20g inactive=365d use_temp_path=off;

        # Cache only success status codes; in particular we don't want to cache 404s.
        # See https://serverfault.com/a/690258/128321
        map $status $cache_header {
          200     "public";
          302     "public";
          default "no-cache";
        }
        access_log /var/log/nginx/access.log;
      '';

      virtualHosts = {
        "nadache" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 9999;
            }
          ];
          extraConfig =
            ''
              resolver 8.8.8.8;
            ''
            + (lib.strings.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList (n: v: ''
                set $upstream_endpoint_${san n} ${v};
              '') cfg.substituterMirrorMap
            ));
          # TODO locations should probably use concatMapAttrs
          locations = lib.attrsets.mergeAttrsList (
            lib.flip lib.mapAttrsToList cfg.substituterMirrorMap (
              n: v: {
                "/${n}" = {
                  root = "${cfg.cacheRoot}/public-nix-cache";
                  extraConfig = ''
                    expires max;
                    add_header Cache-Control $cache_header always;
                    # Ask the upstream server if a file isn't available locally
                    error_page 404 = @fallback_${n};
                  '';
                };

                # can't use a ogbal extra upstream_endpoint, stick in in where needed
                # extraConfig = ''
                #   # Using a variable for the upstream endpoint to ensure that it is
                #   # resolved at runtime as opposed to once when the config file is loaded
                #   # and then cached forever (we don't want that):
                #   # see https://tenzer.dk/nginx-with-dynamic-upstreams/
                #   # This fixes errors like
                #   #   nginx: [emerg] host not found in upstream "upstream.example.com"
                #   # when the upstream host is not reachable for a short time when
                #   # nginx is started.
                #   # resolver 1.1.1.1;
                #   set $upstream_endpoint ${v};
                # '';

                "@fallback_${n}" = {
                  proxyPass = "https://$upstream_endpoint_${san n}";
                  # resolver 1.1.1.1;
                  # set $upstream_endpoint ${v};
                  extraConfig = ''
                    rewrite /${n}/(.*) /$1 break;
                    proxy_cache cachecache;
                    proxy_cache_valid  200 302  60d;
                    expires max;
                    add_header Cache-Control $cache_header always;
                  '';
                };

                # We always want to copy cache.nixos.org's nix-cache-info file,
                # and ignore our own, because `nix-push` by default generates one
                # without `Priority` field, and thus that file by default has priority
                # 50 (compared to cache.nixos.org's `Priority: 40`), which will make
                # download clients prefer `cache.nixos.org` over our binary cache.
                "= ${n}/nix-cache-info" = {
                  # Note: This is duplicated with the `@fallback` above,
                  # would be nicer if we could redirect to the @fallback instead.
                  proxyPass = "https://$upstream_endpoint_${san n}";
                  # resolver 1.1.1.1;
                  # set $upstream_endpoint ${v};
                  extraConfig = ''
                    rewrite /${n}/(.*) /$1 break;
                    proxy_cache cachecache;
                    proxy_cache_valid  200 302  60d;
                    expires max;
                    add_header Cache-Control $cache_header always;
                  '';
                };
              }
            )
          );
        };
      };
    };
  };
}
