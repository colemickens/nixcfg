{ writeShellScriptBin
, symlinkJoin
, freerdp
, wayland-proxy-virtwl
, xwayland
}:

let
  wlproxylaunch = writeShellScriptBin "wlproxylaunch" ''
    pkill -9 -f wayland-proxy-virtwl
    ${wayland-proxy-virtwl}/bin/wayland-proxy-virtwl \
      --wayland-display=wayland-2 \
      --xwayland-binary=${xwayland}/bin/Xwayland \
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
  rdp-sly = writeShellScriptBin "rdp-sly" ''
    RDPUSER="cole.mickens@gmail.com"
    RDPPASS="$(gopass show -o "websites/microsoft.com/cole.mickens@gmail.com")"

    RDPHOST="''${RDPHOST:-"192.168.1.11"}"

    ${freerdp}/bin/wlfreerdp
      /v:"''${RDPHOST}" \
      /u:"''${RDPUSER}" \
      /p:"''${RDPPASS}" \
      /rfx +fonts /dynamic-resolution /compression-level:2
  '';
in
symlinkJoin {
  name = "commands-gui";
  paths = [
    wlproxylaunch
    rdp-sly
  ];
}

