{ pkgs, ...}:

let
  rev = "master";
  #n = import (import ../imports/nixpkgs-chromium);
  st = builtins.fetchTarball { url="https://github.com/colemickens/nixpkgs-chromium/archive/master.tar.gz"; };
  n = import st;
in
{
  config = {
    environment.systemPackages = [ n.chromium-dev-wayland ];
  };
}
