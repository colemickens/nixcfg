{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.cf-ts-sync;
in
{
  imports = [
    (mkRemovedOptionModule
      [ "services" "cfdyndns" "apikey" ]
      "Use services.cfdyndns.apikeyFile instead.")
  ];

  # TODO: this entire thing could be a lil rust app that uses whatever rust-lego client uses for backends and then could support different VPN planes too?

  options = {
    services.cfdyndns = {
      enable = mkEnableOption "Sync Tailscale records to Cloudflare";

      secretsFile = mkOption {
        # load the secrets file into the systemd service
      }

      apikeyFile = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          The path to a file containing the API Key
          used to authenticate with CloudFlare.
        '';
      };

      records = mkOption {
        default = [];
        example = [ "host.tld" ];
        type = types.listOf types.str;
        description = ''
          The records to update in CloudFlare.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cfdyndns = {
      description = "CloudFlare Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      serviceConfig = {
        Type = "simple";
        User = config.ids.uids.cfdyndns;
        Group = config.ids.gids.cfdyndns;
      };
      environment = {
        CLOUDFLARE_EMAIL="${cfg.email}";
        CLOUDFLARE_RECORDS="${concatStringsSep "," cfg.records}";
      };
      script = ''
        ${optionalString (cfg.apikeyFile != null) ''
          export CLOUDFLARE_APIKEY="$(cat ${escapeShellArg cfg.apikeyFile})"
        ''}
        ${pkgs.cfdyndns}/bin/cfdyndns
      '';
    };

    users.users = {
      cfdyndns = {
        group = "cfdyndns";
        uid = config.ids.uids.cfdyndns;
      };
    };

    users.groups = {
      cfdyndns = {
        gid = config.ids.gids.cfdyndns;
      };
    };
  };
}
