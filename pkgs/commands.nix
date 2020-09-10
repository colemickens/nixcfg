{ pkgs }:

{
  gpgssh = pkgs.writeShellScriptBin "gpgssh" ''
    lpath="$(${pkgs.gpg2}/bin/gpgconf --list-dirs agent-extra-socket)
    rpath="$(${pkgs.openssh}/bin/ssh "$@" gpgconf --list-dirs agent-socket)
    ssh \
        -o "RemoteForward $rpath:$lpath" \
        -o StreamLocalBindUnlink=yes \
        -A "$@"
  '';
  reboot-nixos = pkgs.writeShellScriptBin "reboot-nixos" ''
    next="$(sudo efibootmgr | rg "Boot(\d+)\*+ Linux Boot Manager" -r '$1')"
    sudo efibootmgr --bootnext "$next"
  '';
  reboot-windows = pkgs.writeShellScriptBin "reboot-windows" ''
    next="$(sudo efibootmgr | rg "Boot(\d+)\*+ Windows Boot Manager" -r '$1')"
    sudo efibootmgr --bootnext "$next"
  '';
}