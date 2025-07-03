{ pkgs, config, ... }:

let
  cole_uid = config.users.users.cole.uid;
  gpgKeyId = "0x9758078DE5308308";
  gpgCardId = "D2760001240100000006071267080000";
  gpgSshSocket = "/run/user/${builtins.toString cole_uid}/gnupg/d.kbocp7uc7zjy47nnek3436ij/S.gpg-agent.ssh";

  gnupg = pkgs.gnupg;
  openssh = pkgs.openssh;
  tailscale = pkgs.tailscale;
  asciinema = pkgs.asciinema;

  gpg-relearn = (
    pkgs.writeShellScriptBin "gpg-relearn" ''
      gpg-connect-agent "scd serialno" "learn --force" /bye
    ''
  );

  _gpgssh = (
    pkgs.writeShellScriptBin "gpgssh" ''
      [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
      set -euo pipefail

      host=$1; shift

      lpath="$(${gnupg}/bin/gpgconf --list-dirs agent-socket)"
      rpath="$(${openssh}/bin/ssh "$host" -- "\
        pkill -9 gpg-agent; \
        systemctl --user stop gpg-agent.service; \
        pkill -9 gpg-agent; \
        p=\$(gpgconf --list-dirs agent-socket); rm \$p*; echo \$p")"

      ssh \
          -o "RemoteForward $rpath:$lpath.extra" \
          -o StreamLocalBindUnlink=yes \
          -A "$host" -t 'fix-ssh-remote || true; which zsh >/dev/null && exec zsh -l || exec bash -l'
    ''
  );
  gssh = (
    pkgs.writeShellScriptBin "gssh" ''
      [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
      set -euo pipefail
      host="''${1}"; shift
      ip="$(${tailscale}/bin/tailscale ip --6 "$host")"
      ${_gpgssh}/bin/gpgssh cole@"$ip"
    ''
  );

  rec-cmd = (
    pkgs.writeShellScriptBin "rec" ''
      ${asciinema}/bin/asciinema rec "''${HOME}/''${1}.cast" -c "zellij attach -c ''${1}"
    ''
  );

  zj = (
    pkgs.writeShellScriptBin "zj" ''
      zellij a -c "''${1:-"$(hostname)"}"
    ''
  );

  devenv = (
    pkgs.writeShellScriptBin "devenv" ''
      nix develop $HOME/code/nixcfg#devenv"''${@}"
    ''
  );

  nixcfg = (
    pkgs.writeShellScriptBin "nixcfg" ''
      nix develop $HOME/code/nixcfg -c $HOME/code/nixcfg/main.nu "''${@}"
    ''
  );

  fix-ssh = (
    pkgs.writeShellScriptBin "fix-ssh" ''
      set -x
      cole_uid=$(id -u cole)
      ln -sf ${gpgSshSocket} "/run/user/''${cole_uid}/sshagent"
    ''
  );
  fix-ssh-remote = (
    pkgs.writeShellScriptBin "fix-ssh-remote" ''
      set -x
      ent="$(ls -t /tmp/ssh-**/agent.* | head -1)"
      ln -sf $ent "/run/user/$(id -u)/sshagent"
      export SSH_AUTH_SOCK="/run/user/$(id -u)/sshagent"
      # wtf is this even for
      # ssh-add -L | ssh-add -T /dev/stdin
      ssh-add -l
    ''
  );

  fix-gpg = (
    pkgs.writeShellScriptBin "fix-gpg" ''
      set -x
      cole_uid=$(id -u cole)
      ln -sf ${gpgSshSocket} /run/user/''${cole_uid}/sshagent
      gpg --card-status >/dev/null
      ssh localhost true
      echo "foo" | gpg --sign &>/dev/null # somehow fixes some weird cases where remote gpg gets hung up when it hasn't been used locally
    ''
  );

  fix-gpg-key = (
    pkgs.writeShellScriptBin "fix-gpg-key" ''
      set -x
      # check if key is known
      if ! gpg --list-keys "${gpgKeyId}" | grep "${gpgKeyId}" ; then
        curl -L https://github.com/colemickens.gpg | gpg --import
        (echo 5; echo y; echo save) |
          gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "${gpgKeyId}" trust >/dev/null 2>&1
      fi
    ''
  );

  _zssh = (
    pkgs.writeShellScriptBin "_zssh" ''
      [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
      set -euo pipefail
      ipver="''${1}"; shift
      host="''${1}"; shift
      while true; do
        if ip="$(${tailscale}/bin/tailscale ip $ipver "$host")"; then break; fi
      done
      while true; do
        set +e
        ssh -o ConnectTimeout=5 -t cole@"$ip" "''${@}"
      done
    ''
  );
  zssh4 = (
    pkgs.writeShellScriptBin "zssh4" ''
      ${_zssh} --4 "''${@}"
    ''
  );
  zssh6 = (
    pkgs.writeShellScriptBin "zssh6" ''
      ${_zssh} --6 "''${@}"
    ''
  );
  mickfwd = (
    pkgs.writeShellScriptBin "mickfwd" ''
      ssh  -L 3389:192.168.1.6:3389 -L 8443:192.168.1.9:8443 -L 8123:192.168.1.9:8123 "cole@$(tailscale ip --4 xeep)"
    ''
  );
  nixclean = (
    pkgs.writeShellScriptBin "nixclean" ''
      nix-env --profile ~/.local/state/nix/profiles/home-manager --delete-generations +1
      sudo nix-collect-garbage -d
      sudo nix-collect-garbage
    ''
  );

  ipv6ctl = (
    pkgs.writeShellScriptBin "ipv6ctl" ''
      set -eou pipefail
      if [[ "''${1:-}" == "on" ]]; then
        sysctl -w net.ipv6.conf.all.disable_ipv6=0
        sysctl -w net.ipv6.conf.default.disable_ipv6=0
        sysctl -w net.ipv6.conf.wlan0.disable_ipv6=0
      elif [[ "''${1:-}" == "off" ]]; then
        sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sysctl -w net.ipv6.conf.default.disable_ipv6=1
        sysctl -w net.ipv6.conf.wlan0.disable_ipv6=1
      fi
    ''
  );
  aw = (
    pkgs.writeShellScriptBin "aw" ''
      set -eou pipefail
      if [[ "''${1:-}" == "on" ]]; then
        adb shell svc wifi disable
        adb shell svc usb setFunctions ncm
      elif [[ "''${1:-}" == "off" ]]; then
        adb shell svc usb setFunctions
        adb shell svc wifi enable
      fi
    ''
  );

  ## WORK RELATED

  work-update-machine = (
    pkgs.writeShellScriptBin "work-update-machine" ''
      set -x
      set -euo pipefail
      export ref="$(git ls-remote https://github.com/colemickens/nixcfg -b main | cut -f 1)"
      export toplevel="$(nix build --no-link --print-out-paths "github:colemickens/nixcfg?ref=''${ref}#toplevels.$(hostname)")"
      echo "$toplevel" | cachix push colemickens
      sudo nix build --no-link --profile /nix/var/nix/profiles/system "$toplevel"
      sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
    ''
  );
  work-port-forward = (
    pkgs.writeShellScriptBin "work-port-forward" ''
      set -x
      set -euo pipefail
      ssh -N -L 8234:localhost:8234 -L 8250:localhost:8250 \
        -L 8080:localhost:8080 -L 3000:localhost:3000 \
          "cole@$(tailscale ip --4 ds-ws-colemickens)"
    ''
  );

in
{
  config = {
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "cole-custom-commands";
        paths = [
          gssh
          gpg-relearn
          fix-gpg
          fix-gpg-key

          work-update-machine
          work-port-forward

          fix-ssh
          fix-ssh-remote
          rec-cmd
          zj
          devenv
          nixcfg

          zssh4
          zssh6

          mickfwd
          nixclean

          ipv6ctl
          aw
        ];
      })
    ];
  };
}
