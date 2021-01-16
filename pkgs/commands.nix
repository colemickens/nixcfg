{ gnupg, openssh, efibootmgr
, writeShellScriptBin, linkFarmFromDrvs }:

let
  efibootmgr_ = "${efibootmgr}/bin/efibootmgr";

  name = "cole-custom-commands";
  drvs = [
    (writeShellScriptBin "gpgssh" ''
      #!/nix/store/zcl19h06322c3kss6bvf05w2pxg4kfll-bash-4.4-p23/bin/bash
      set -x
      set -euo pipefail

      lpath="$(${gnupg}/bin/gpgconf --list-dirs agent-socket)"
      rpath="$(${openssh}/bin/ssh "$1" -- "\
        pkill -9 gpg-agent; \
        systemctl --user stop gpg-agent.service; \
        pkill -9 gpg-agent; \
        gpgconf --list-dirs agent-socket \
          | xargs -d $'\n' sh -c 'for arg do rm -i "\$arg"; echo "\$arg"; done' _")"

      ssh \
          -o "RemoteForward $rpath:$lpath.extra" \
          -o StreamLocalBindUnlink=yes \
          -A "$@"
    '')

    (writeShellScriptBin "gpg-fix" ''
      set -x
      sudo systemctl stop pcscd.service
      sudo systemctl stop pcscd.socket
      systemctl --user stop gpg-agent.service
      sudo pkill -f gpg-agent
      systemctl --user restart gpg-agent.socket
      systemctl --user restart gpg-agent-extra.socket
      systemctl --user restart gpg-agent-ssh.socket
      export GPG_TTY=$(tty)
      gpg-connect-agent updatestartuptty /bye
      sleep 1
      sudo systemctl start pcscd.service
      sleep 1
      gpg --card-status
    '')

    (writeShellScriptBin "pulse-fix" ''
      set -x
      systemctl --user daemon-reload
      systemctl --user start pipewire.service
      systemctl --user start pipewire-pulse.socket
      pkill waybar; sleep 1
      swaymsg reload
    '')

    (writeShellScriptBin "reboot-nixos" ''
      next="$(sudo ${efibootmgr_} | rg "Boot(\d+)\*+ Linux Boot Manager" -r '$1')"
      sudo ${efibootmgr_} --bootnext "$next"
    '')
    (writeShellScriptBin "reboot-windows" ''
      next="$(sudo ${efibootmgr_} | rg "Boot(\d+)\*+ Windows Boot Manager" -r '$1')"
      sudo ${efibootmgr_} --bootnext "$next"
    '')
  ];
in
  #linkFarmFromDrvs name drvs
  drvs
