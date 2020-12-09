{ gnupg, openssh, efibootmgr
, writeShellScriptBin, linkFarmFromDrvs }:

let
  efibootmgr_ = "${efibootmgr}/bin/efibootmgr";

  name = "cole-custom-commands";
  drvs = [
    (writeShellScriptBin "gpgssh" ''
      set -x
      lpath="$(${gnupg}/bin/gpgconf --list-dirs agent-socket)
      rpath="$(${openssh}/bin/ssh "$1" gpgconf --list-dirs agent-socket)
      ssh \
          -o "RemoteForward $rpath:$lpath.extra" \
          -o "RemoteForward $rpath.ssh:$lpath.ssh" \
          -o StreamLocalBindUnlink=yes \
          -A "$@"
    '')

    (writeShellScriptBin "fix-gpg" ''
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
      sleep 3
      sudo systemctl start pcscd.service
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
