{ pkgs, ... }:

let
  reboot-linux = pkgs.writeShellScriptBin "reboot-linux" ''
    sudo ${pkgs.efibootmgr}/bin/efibootmgr --bootnext 0000
  '';

  wlproxylaunch = pkgs.writeShellScriptBin "wlproxylaunch" ''
    pkill -9 -f wayland-proxy-virtwl
    ${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl \
      --wayland-display=wayland-2 \
      --xwayland-binary=${pkgs.xwayland}/bin/Xwayland \
      --x-display=2 \
      --verbose &

    sleep 1
    echo
    echo "Ready! Example usage (in a new terminal):" >&2
    echo " \$ export WAYLAND_DISPLAY=wayland-2; export DISPLAY=:2" >&2
    echo " \$ ledger-live-desktop # for example" >&2
    echo
    wait
  '';
in
{
  config = {
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "commands-gui";
        paths = [
          reboot-linux
          wlproxylaunch
        ];
      })
    ];
  };
}
