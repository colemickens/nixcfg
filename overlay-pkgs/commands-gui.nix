{ pkgs }:

{
  riot-ssb = pkgs.writeShellScriptBin "riot-ssb" ''
    ${pkgs.firefox}/bin/firefox -p stable-default --ssb 'https://riot.im/develop'
  '';
  rdp-sly = pkgs.writeShellScriptBin "rdp-sly" ''
    RDPUSER="cole.mickens@gmail.com"
    RDPPASS="$(gopass show -o "websites/microsoft.com/cole.mickens@gmail.com")"

    RDPHOST="''${RDPHOST:-"192.168.1.11"}"

    wlfreerdp /v:"''${RDPHOST}" /u:"''${RDPUSER}" /p:"''${RDPPASS}" \
    /rfx +fonts /dynamic-resolution /compression-level:2
  '';
}