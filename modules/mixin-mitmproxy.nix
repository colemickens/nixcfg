{ lib, pkgs, ... }:

let
  crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
  crtFile = pkgs.copyPathToStore "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
in
{
  config = {
    security.pki.certificateFiles =
      if (lib.pathExists "${crtFilePath}")
        then [ "${crtFile}" ]
        else [];
  };
}
