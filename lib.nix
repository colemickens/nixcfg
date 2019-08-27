{...}:

rec
{
  # overlay will load an overlay, either from:
  #  ../overlays/{name}
  #  ./imports/overlays/{name}
  overlay = name: url:
    let
      localimportpath = ../overlays + "/${name}";
      importpath = ./imports/overlays + "/${name}";
    in
      if builtins.pathExists localimportpath then
        (import "${localimportpath}")
      else if builtins.pathExists importpath then
        (import (import "${importpath}").src)
      else (import ./you-must-vendor-overlay-imports);
      #else if builtins.pathExists ../imports/overlays/${name} then
      #  (import ../imports/overlays/${name})
      #else
      #  (import (builtins.fetchTarball "${url}"));

  # TODO: see if there's way to simplify this, (note: nixpkgs.nixos does not eval overlays)
  # (also though, I think this winds up importing the nixpkgs checkout to /nix/store, oh well)
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
