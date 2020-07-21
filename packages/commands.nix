{ pkgs }:

{
  gpgssh = pkgs.writeShellScriptBin "gpgssh" ''
    lpath="$(gpgconf --list-dirs agent-extra-socket)
    rpath="$(ssh "$@" gpgconf --list-dirs agent-extra-socket)
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