{ gnupg, openssh, efibootmgr, tailscale
, writeShellScriptBin
, linkFarmFromDrvs
, symlinkJoin
}:

let
  efibootmgr_ = "${efibootmgr}/bin/efibootmgr";

  tsip = (writeShellScriptBin "tsip" ''
    ${tailscale}/bin/tailscale ip --6 "$1")"
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
        -A "$host" 'ssh-fix || true; exec \$SHELL -l'
  '');

  name = "cole-custom-commands";
  drvs = [
    gssh
    gpgssh

    (writeShellScriptBin "gpg-fix" ''
      ln -sf /run/user/1000/gnupg/S.gpg-agent.ssh /run/user/1000/sshagent
      set -x
      CO='\033[0;30m'
      NC='\033[0m' # No Color
      printf "''${CO}"
      sudo systemctl stop pcscd.service
      sudo systemctl stop pcscd.socket
      systemctl --user stop gpg-agent.service
      sudo pkill -f gpg-agent
      systemctl --user restart gpg-agent.socket
      systemctl --user restart gpg-agent-extra.socket
      systemctl --user restart gpg-agent-ssh.socket
      export GPG_TTY=$(tty)
      gpg-connect-agent updatestartuptty /bye
      sleep 0.1
      sudo systemctl start pcscd.service
      sleep 0.1
      # check if key is known
      KEYID="0x9758078DE5308308"
      if ! gpg --list-keys $KEYID | grep $KEYID ; then
        curl -L https://github.com/colemickens.gpg | gpg --import
        (echo 5; echo y; echo save) |
          gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$KEYID" trust
      fi
      printf "''${NC}"
      gpg --card-status
    '')

    (writeShellScriptBin "ssh-fix" ''
      ent="$(ls /tmp/ssh-**/agent.* | head -1)"
      ln -sf $ent /run/user/1000/sshagent
      export SSH_AUTH_SOCK="/run/user/1000/sshagent"
      ssh-add -l
    '')

    # (writeShellScriptBin "pulse-fix" ''
    #   set -x
    #   systemctl --user daemon-reload
    #   systemctl --user start pipewire.service
    #   systemctl --user start pipewire-pulse.socket
    #   pkill waybar; sleep 1
    #   swaymsg reload
    # '')

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

