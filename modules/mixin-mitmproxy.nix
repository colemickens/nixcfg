{ lib, pkgs, ... }:

let
  crtFile = pkgs.copyPathToStore "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
in
{
  config = {
    security.pki.certificateFiles =
      if (lib.pathExists "${crtFile}")
        then [ "${crtFile}" ]
        else [];
  };
}