{ pkgs, ...}:

let
  rev = "master";
  nixpkgsChromiumSet = import (builtins.fetchTarball {
    url = "https://github.com/colemickens/nixpkgs-chromium/archive/${rev}.tar.gz";
  }) { pkgs = pkgs; };
in
{
  config = {
    #environment.systemPackages = [ nixpkgsChromiumSet.chromium-git ];
  };
}
