{ gnupg
, pinentry
, openssh
, efibootmgr
, tailscale
, asciinema
, msr-tools
, skim
, jq
, wl-clipboard
, writeShellScriptBin
, linkFarmFromDrvs
, symlinkJoin
, python3Packages
, fetchurl
}:

let
  efibootmgr_ = "${efibootmgr}/bin/efibootmgr";
  writePython3Bin = python3Packages.writePython3Bin;

  gpgKeyId = "0x9758078DE5308308";
  gpgCardId = "D2760001240100000006071267080000";
  gpgSshSocket = "/run/user/1000/gnupg/d.kbocp7uc7zjy47nnek3436ij/S.gpg-agent.ssh";

  name = "cole-custom-commands";
  drvs = [
    # PICKER: EMOJI
    (
      let
        emojis = fetchurl {
          url = "https://raw.githubusercontent.com/muan/emojilib/v3.0.6/dist/emoji-en-US.json";
          sha256 = "sha256-wf7zsIEbX/diLwmVvnN2Goxh2V5D3Z6nbEMSb5pSGt0=";
        };
      in
      writeShellScriptBin "emoji-pick" ''
        cat "${emojis}" \
          | "${jq}/bin/jq" --raw-output '. | to_entries | .[] | .key + " " + (.value | join(" ") | sub("_"; " "; "g"))' \
          | "${skim}/bin/sk" \
          | "${wl-clipboard}/bin/wl-copy"
      ''
    )
    # PICKER: GOPASS
    (writeShellScriptBin "gopass-clip" ''
      gopass show --clip "$(gopass ls --flat | sk --height '100%' -p "pass> ")"
    '')
    (writeShellScriptBin "gopass-totp" ''
      gopass totp --clip "$(gopass ls --flat | sk --height '100%' -p "totp> ")"
    '')

    # SSH QUICK HELPERS
    (writeShellScriptBin "gssh" ''
      [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
      set -euo pipefail
      host="''${1}"; shift
      ip="$(${tailscale}/bin/tailscale ip --6 "$host")"
      gpgssh cole@"$ip"
    '')
    (writeShellScriptBin "zssh4" ''
      _zssh --4 "''${@}"
    '')
    (writeShellScriptBin "zssh6" ''
      _zssh --6 "''${@}"
    '')
    (writeShellScriptBin "_zssh" ''
      [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
      set -euo pipefail
      ipver="''${1}"; shift
      host="''${1}"; shift
      while true; do
        if ip="$(${tailscale}/bin/tailscale ip $ipver "$host")"; then break; fi
      done
      while true; do
        set +e
        ssh -o ConnectTimeout=5 cole@"$ip" "''${@}"
      done
    '')
    (writeShellScriptBin "gpgssh" ''
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
    '')

    # ASCIINEMA
    (writeShellScriptBin "rec" ''
      ${asciinema}/bin/asciinema rec "''${HOME}/''${1}.cast" -c "zellij attach -c ''${1}"
    '')

    # ZELLIJ
    (writeShellScriptBin "zj" ''
      zellij a -c "''${1:-"$(hostname)"}"
    '')

    # DEVENV
    (writeShellScriptBin "devenv" ''
      nix develop $HOME/code/nixcfg#devenv "''${@}"
    '')

    # # NIXCFG helper
    # (writeShellScriptBin "nixcfg" ''
    #   nixcfg="$HOME/code/nixcfg"
    #   cd $nixcfg
    #   nu ./misc/main.nu "''${@}"
    # '')

    # GPG/SSH FIXUP
    (writeShellScriptBin "gpg-fix" ''
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
    '')
    (writeShellScriptBin "ssh-fix" ''
      ent="$(ls -t /tmp/ssh-**/agent.* | head -1)"
      ln -sf $ent /run/user/1000/sshagent
      export SSH_AUTH_SOCK="/run/user/1000/sshagent"
      ssh-add -L | ssh-add -T /dev/stdin
      ssh-add -l
    '')

  ];
in
(symlinkJoin { name = "commands"; paths = drvs; })

