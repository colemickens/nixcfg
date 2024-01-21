{ config, lib, pkgs, ... }:

with lib;

let cfg = config.programs.tailscale-autojoin;
in {
  meta.maintainers = with maintainers; [ colemickens ];

  options.programs.tailscale-autojoin = {
    enable = mkEnableOption "Tailscale auto-join on shell init";

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

    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        echo "trying to connect to tailscale" &>2
        sudo tailscale login --qr
      )
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
          \"${pkgs.tailscale}/bin/tailscale\" up -authkey \"$(cat ${cfg.tokenFile})\" \
        "

        # should we cleanup?
        if [[ "cleanup" == "${if cfg.cleanupAuthkey then "cleanup" else "no"}" ]]; then
          rm -f "${cfg.tokenFile}"
        fi
    '';
  };
};
}
