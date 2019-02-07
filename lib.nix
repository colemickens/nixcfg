{ ... }:

let
  overlay = name: url:
    if builtins.pathExists "/home/cole/code/overlays/${name}"
    then (import "/home/cole/code/overlays/${name}")
    else (import (builtins.fetchTarball "${url}"));

  # TODO:
  # there's a lot to not love here, probably:
  # 1. I suspect there's a much more succinct way of doing this.
  #    (though I don't think it's pkgs.nixos due to how it treats overlays? right?)
  # 2. The version handling feels a bit fragile and relies on how I return nixpkgs, along with rev from
  #    ../nixpkgs/{nixpkgs}/default.nix
  #    but, it also means that it works identically here from install media in a clean scenario

  # TODO: closure bloat (TODO: find the nixcon presentation about closure reduction between dupe system defs)

  mkSystem = { nixpkgs, localnixpkgs ? null, nixoscfg, system }:
    let
      importpath = if localnixpkgs != null && builtins.pathExists localnixpkgs then localnixpkgs else nixpkgs.pkgs;
      pkgs = import importpath {
        inherit system;
        inherit (machine.config.nixpkgs) config overlays;
      };

      extraModules = if localnixpkgs != null && builtins.pathExists localnixpkgs then [] else 
        [ ({config, ...}: {
          system.nixos.revision = nixpkgs.meta.revShort;
          system.nixos.versionSuffix = ".git.${nixpkgs.meta.revShort}";
        }) ];
      machine = import "${importpath}/nixos/lib/eval-config.nix" {
        inherit (pkgs) system;
        inherit pkgs;
        modules = [ nixoscfg ] ++ extraModules;
      };
    in
      machine;
in
  {
    inherit overlay;
    inherit mkSystem;
  }
