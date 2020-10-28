{ #wlfreerdp
#,
writeShellScriptBin, linkFarmFromDrvs }:

let
  name = "cole-custom-commands-gui";
  drvs = [
    (writeShellScriptBin "rdp-sly" ''
      RDPUSER="cole.mickens@gmail.com"
      RDPPASS="$(gopass show -o "websites/microsoft.com/cole.mickens@gmail.com")"

      RDPHOST="''${RDPHOST:-"192.168.1.11"}"

      #{wlfreerdp}/bin/
      wlfreerdp \
        /v:"''${RDPHOST}" \
        /u:"''${RDPUSER}" \
        /p:"''${RDPPASS}" \
        /rfx +fonts /dynamic-resolution /compression-level:2
    '')
  ];
in
  linkFarmFromDrvs name drvs
