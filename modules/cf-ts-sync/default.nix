# https://github.com/MunifTanjim/scripts.sh/blob/main/sync-cloudflare-dns-records-with-tailscale

{ config, pkgs, ... }:

let
  # TODO: Expose these as module thingies
  script = pkgs.substituteAll {
    src = ./script.js;
    dir = "/";
    DOMAIN_NAME = "cleo.cat";
    DNS_RECORD_NAMESPACE = "ts";
  };
  syncer = pkgs.writeScript "sync.sh" ''
    "${pkgs.zx}/bin/zx "${script}"
  '';
in {
  config = {
    systemd.services.cfdyndns = {
      description = "Sync Tailscale to Cloudflare";
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
  };
}
