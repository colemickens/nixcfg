{
  pkgs,
  config,
  ...
}:

# note: we intentionally don't use full paths so that these scripts
# don't accidentallly pull in crap (for example, asus-dgpu is only relevant
# for 'zeph', etc)
let
  asus-dgpu = pkgs.writeShellScriptBin "asus-dgpu" ''
    sudo asusctl bios -D 0; sudo efibootmgr --bootnext 0000
  '';
  asus-igpu = pkgs.writeShellScriptBin "asus-igpu" ''
    sudo asusctl bios -D 1; sudo efibootmgr --bootnext 0000
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
# rdp-sly = pkgs.writeShellScriptBin "rdp-sly" ''
#   RDPUSER="cole.mickens@gmail.com"
#   RDPPASS="$(gopass show -o "websites/microsoft.com/cole.mickens@gmail.com")"
#   RDPHOST="''${RDPHOST:-"192.168.1.11"}"
#   ${pkgs.freerdp}/bin/wlfreerdp
#     /v:"''${RDPHOST}" \
#     /u:"''${RDPUSER}" \
#     /p:"''${RDPPASS}" \
#     /rfx +fonts /dynamic-resolution /compression-level:2
# '';
# gs = pkgs.writeShellScriptBin "gs" ''
#   set -x
#   export ENABLE_GAMESCOPE_WSI=1
#   ${gamescope}/bin/gamescope -w 1920 -h 1080 -r 120 --hdr-enabled -- "''${@}"
# '';
{
  config = {
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "commands-gui";
        paths = [
          wlproxylaunch

          asus-dgpu
          asus-igpu
          # rdp-sly
          # gs
        ];
      })
    ];
  };
}
