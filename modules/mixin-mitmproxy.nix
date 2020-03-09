{ lib, pkgs, ... }:

let
  crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
  crtFile = pkgs.copyPathToStore "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
in
{
  config = {
    environment.systemPackages = [ pkgs.mitmproxy ];
    security.pki.certificateFiles =
      if (lib.pathExists "${crtFilePath}")
        then [ "${crtFile}" ]
        else [];
  };
}
