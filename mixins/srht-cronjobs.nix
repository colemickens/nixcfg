{ pkgs, lib, ... }: 

let
  doBuild = repo: pkgs.writeScript "doBuild.sh" ''
    #! /usr/bin/env bash
    set -eu
    mkdir -p /tmp/overlaydir
    cd /tmp/overlaydir
    if [[ ! -d ./${repo} ]]; then
      git clone https://github.com/colemickens/${repo}
    fi
    cd ${repo}
    git remote update
    git reset --hard origin/master
    bash .ci/srht-submit.sh
  '';
  repos = [
    "nixpkgs-wayland"
    "flake-firefox-nightly"
  ];
  genPrefixAttrs = prefix: names: f: lib.listToAttrs (map (n: lib.nameValuePair "${prefix}${n}" (f n)) names);
in
{
  systemd.timers = genPrefixAttrs "srht-" repos (repo:
    {
        wantedBy = [ "timers.target" ];
        partOf = [ "srht-${repo}.service" ];
        timerConfig.OnCalendar = "hourly";
    }
  );

  systemd.services = genPrefixAttrs "srht-" repos (repo:
    {
      # I need these in path for the `srht-submit.sh` script in the repo,
      # so no point in trying to embed them in doBuild, directly, above.
      path = with pkgs; [ bash curl jq git ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        User = "cole";
        ExecStart = ''${doBuild repo}'';
      };
    }
  );
}
