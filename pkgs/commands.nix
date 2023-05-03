{ gnupg
, openssh
, tailscale
, asciinema
, writeShellScriptBin
, symlinkJoin
}:

let
  gpgKeyId = "0x9758078DE5308308";
  gpgCardId = "D2760001240100000006071267080000";
  gpgSshSocket = "/run/user/1000/gnupg/d.kbocp7uc7zjy47nnek3436ij/S.gpg-agent.ssh";

  reboot-linux-dgpu = (writeShellScriptBin "reboot-linux-dgpu" ''
    # set dGPU extreme
    # set next boot
    # reboot
  '');
  reboot-linux-igpu = (writeShellScriptBin "reboot-linux-igpu" ''
    # set dGPU off
    # set next boot
    # reboot
  '');
  reboot-windows = (writeShellScriptBin "reboot-windows" ''
    # set dGPU extreme
    # set next boot
    # reboot
  '');

  gpg-relearn = (writeShellScriptBin "gpg-relearn" ''
    gpg-connect-agent "scd serialno" "learn --force" /bye
  '');

  _gpgssh = (writeShellScriptBin "gpgssh" ''
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
        -A "$host" -t 'ssh-fix || true; which zsh >/dev/null && exec zsh -l || exec bash -l'
  '');
  gssh = (writeShellScriptBin "gssh" ''
    [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
    set -euo pipefail
    host="''${1}"; shift
    ip="$(${tailscale}/bin/tailscale ip --6 "$host")"
    ${_gpgssh}/bin/gpgssh cole@"$ip"
  '');

  rec-cmd = (writeShellScriptBin "rec" ''
    ${asciinema}/bin/asciinema rec "''${HOME}/''${1}.cast" -c "zellij attach -c ''${1}"
  '');

  zj = (writeShellScriptBin "zj" ''
    zellij a -c "''${1:-"$(hostname)"}"
  '');

  devenv = (writeShellScriptBin "devenv" ''
    nix develop $HOME/code/nixcfg#devenv "''${@}"
  '');

  nixcfg = (writeShellScriptBin "nixcfg" ''
    nix develop $HOME/code/nixcfg -c /home/cole/code/nixcfg/main.nu "''${@}"
  '');

  fix-ssh = (writeShellScriptBin "fix-ssh" ''
    set -x
    ln -sf ${gpgSshSocket} /run/user/1000/sshagent
  '');
  fix-ssh-remote = (writeShellScriptBin "fix-ssh" ''
    set -x
    ent="$(ls -t /tmp/ssh-**/agent.* | head -1)"
    ln -sf $ent /run/user/1000/sshagent
    export SSH_AUTH_SOCK="/run/user/1000/sshagent"
    ssh-add -L | ssh-add -T /dev/stdin
    ssh-add -l
  '');

  fix-gpg =
    (writeShellScriptBin "fix-gpg" ''
      set -x
      ln -sf ${gpgSshSocket} /run/user/1000/sshagent
      sudo systemctl stop pcscd.service >/dev/null
        sudo systemctl stop pcscd.socket >/dev/null
        systemctl --user stop gpg-agent.service 2>/dev/null
        sudo pkill -f scdaemon
        sudo pkill -f gpg-agent
        systemctl --user restart gpg-agent.socket 2>/dev/null
        systemctl --user restart gpg-agent-extra.socket 2>/dev/null
        systemctl --user restart gpg-agent-ssh.socket 2>/dev/null
        export GPG_TTY=$(tty)
        gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
        sleep 0.1
        sudo systemctl start pcscd.service >/dev/null
        sleep 0.1
        # check if key is known
        if ! gpg --list-keys "${gpgKeyId}" | grep "${gpgKeyId}" ; then
          curl -L https://github.com/colemickens.gpg | gpg --import
          (echo 5; echo y; echo save) |
            gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "${gpgKeyId}" trust >/dev/null 2>&1
        fi
        gpg --card-status >/dev/null
        echo "foo" | gpg --sign &>/dev/null # somehow fixes some weird cases where remote gpg gets hung up when it hasn't been used locally
        ssh localhost true
    '');

  _zssh = (writeShellScriptBin "_zssh" ''
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
  '');
  zssh4 = (writeShellScriptBin "zssh4" ''
    ${_zssh} --4 "''${@}"
  '');
  zssh6 = (writeShellScriptBin "zssh6" ''
    ${_zssh} --6 "''${@}"
  '');

in
(symlinkJoin {
  name = "cole-custom-commands";
  paths = [
    reboot-linux-dgpu
    reboot-linux-igpu
    reboot-windows

    gssh
    gpg-relearn
    fix-gpg
    fix-ssh
    fix-ssh-remote
    rec-cmd
    zj
    devenv
    nixcfg

    zssh4
    zssh6
  ];
})

