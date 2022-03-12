{ gnupg, openssh, efibootmgr, tailscale, code-server
, asciinema
, nixUnstable
, writeShellScriptBin
, linkFarmFromDrvs
, symlinkJoin
}:

let
  efibootmgr_ = "${efibootmgr}/bin/efibootmgr";

  tsip = (writeShellScriptBin "tsip" ''
    ${tailscale}/bin/tailscale ip --6 "$1"
  '');

  gssh = (writeShellScriptBin "gssh" ''
    [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
    set -euo pipefail

    ip="$(${tailscale}/bin/tailscale ip --6 "$1")"
    "${gpgssh}/bin/gpgssh" cole@"$ip"
  '');

  gpgssh = (writeShellScriptBin "gpgssh" ''
    [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
    set -euo pipefail

    host=$1; shift

    lpath="$(${gnupg}/bin/gpgconf --list-dirs agent-socket)"
    rpath="$(${openssh}/bin/ssh "$host" -- "\
      pkill -9 gpg-agent; \
      systemctl --user stop gpg-agent.service; \
      pkill -9 gpg-agent; \
      gpgconf --list-dirs agent-socket \
        | xargs -d $'\n' sh -c 'for arg do rm -f "\$arg"; echo "\$arg"; done' _")"

    ssh \
        -o "RemoteForward $rpath:$lpath.extra" \
        -o StreamLocalBindUnlink=yes \
        -A "$host" -t 'ssh-fix || true; which zsh >/dev/null && exec zsh -l || exec bash -l'
  '');

  name = "cole-custom-commands";
  drvs = [
    tsip
    gssh
    gpgssh
    
    (writeShellScriptBin "gopass-clip" ''
      gopass show --clip "$(gopass ls --flat | sk --height '100%' -p "gopass show --clip> ")"
    '')

    (writeShellScriptBin "gopass-totp" ''
      gopass totp --clip "$(gopass ls --flat | sk --height '100%' -p "gopass totp --clip> ")"
    '')

    (writeShellScriptBin "devenv" ''
      nix develop $HOME/code/nixcfg#devenv "''${@}"
    '')

    (writeShellScriptBin "gpg-fix" ''
      ln -sf /run/user/1000/gnupg/S.gpg-agent.ssh /run/user/1000/sshagent
      set +x
      sudo systemctl stop pcscd.service >/dev/null
      sudo systemctl stop pcscd.socket >/dev/null
      systemctl --user stop gpg-agent.service 2>/dev/null
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
      KEYID="0x9758078DE5308308"
      if ! gpg --list-keys $KEYID | grep $KEYID ; then
        curl -L https://github.com/colemickens.gpg | gpg --import
        (echo 5; echo y; echo save) |
          gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$KEYID" trust >/dev/null 2>&1
      fi
      gpg --card-status >/dev/null
    '')

    (writeShellScriptBin "ssh-fix" ''
      ent="$(ls /tmp/ssh-**/agent.* | head -1)"
      ln -sf $ent /run/user/1000/sshagent
      export SSH_AUTH_SOCK="/run/user/1000/sshagent"
      ssh-add -L | ssh-add -T /dev/stdin
      ssh-add -l
    '')

    (writeShellScriptBin "reboot-nixos" ''
      next="$(sudo ${efibootmgr_} | rg "Boot(\d+)\*+ nixos-grub-shim" -r '$1')"
      sudo ${efibootmgr_} --bootnext "$next"
    '')
    (writeShellScriptBin "reboot-windows" ''
      next="$(sudo ${efibootmgr_} | rg "Boot(\d+)\*+ Windows Boot Manager" -r '$1')"
      sudo ${efibootmgr_} --bootnext "$next"
    '')
  ];
in
  (symlinkJoin { name="commands"; paths=drvs; })

