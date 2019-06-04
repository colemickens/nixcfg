{...}:

let
  home = "/home/cole";
in
{
  overlay = name: url:
    if builtins.pathExists "${home}/code/overlays/${name}"
    then (import "${home}/code/overlays/${name}")
    else (import (builtins.fetchTarball "${url}"));

  mkSystem = { nixpkgs, rev, configFile, extraModules ? [], ... }:
    let
      pkgs = import (nixpkgs) {
        inherit (machine.config.nixpkgs) config overlays;
      };
      machine = import "${nixpkgs}/nixos/lib/eval-config.nix" {
        modules = [
          configFile
          ({config, ...}: {
            system.nixos.revision = rev;
            system.nixos.versionSuffix = ".git.${rev}";
          })
        ] ++ extraModules;
      };
    in
      machine;
}