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
  };

  config = if cfg.enable then {
    # adapted from: https://tailscale.com/blog/nixos-minecraft/

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = with pkgs; ''
        # TODO: there's a better way to do this: tailscaled settle
        sleep 2

        # TODO: does this actually check for auth'd?
        # check if we are already authenticated to tailscale
        status="$(${pkgs.tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        cat "${cfg.tokenFile}" | ${pkgs.tailscale}/bin/tailscale up -authkey -
      '';
    };
  } else {};
}
