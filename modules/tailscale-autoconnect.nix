{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.tailscale-autoconnect;
in {
  meta.maintainers = with maintainers; [ colemickens ];

  options.services.tailscale-autoconnect = {
    enable = mkEnableOption "Tailscale client daemon";

    tokenFile = mkOption {
      type = types.str;
      #default = "";
      example = "/run/keys/tailscale.key";
      description = ''Path to the file containing the tailscale join authkey'';
    };

    cleanupAuthkey = mkOption {
      type = types.bool;
      default = false;
      description = ''Cleanup the authkey path after successful login.'';
    };
  };

  config = lib.mkIf cfg.enable {
    # adapted from: https://tailscale.com/blog/nixos-minecraft/

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";
      after = [ "network-pre.target" "tailscaled.service" ];
      wants = [ "network-pre.target" "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "20";
      };
      script = with pkgs; ''
        set -x
        set -eu

        # TODO: there's a better way to do this: tailscaled settle
        sleep 2

        # TODO: does this actually check for auth'd?
        # check if we are already authenticated to tailscale
        status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r '.BackendState')"
        if [[ "''${status:-""}" == "Running" ]]; then
          # let systemd know we're done :)
          exit 0
        fi

        # otherwise authenticate with tailscale
        "${pkgs.coreutils}/bin/timeout" 10 "${pkgs.bash}/bin/bash" -c "
          \"${pkgs.tailscale}/bin/tailscale\" up -authkey \"$(cat \"${cfg.tokenFile}\")\" \
        "

        # should we cleanup?
        if [[ "cleanup" == "${if cfg.cleanupAuthkey then "cleanup" else "no"}" ]]; then
          rm -f "${cfg.tokenFile}"
        fi
      '';
    };
  };
}
