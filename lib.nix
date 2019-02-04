{ ... }:

let
  # similar to the localnixpkgs override below...
  # this uses an upstream overlay, unless we have it cloned already
  # ideal for repeatability but flexible for day-to-day dev too :)
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
  # but some cool things:
  # we can build the exact system toplevel in both conditions:
  # 1. we're on a clean system and we're `nixos-install`ing a pre-built closure with nixcfg in an offline scenario
  # 2. we're on a day-to-day system where we're tweaking nixpkgs momentarily and have it cloned at /home/cole/code/nixpkgs
  # TODO: ISO MUST PREBAKE NIXCFG (which amkes sense for an offline install... and suggest combinging w/ dotifes))

  mkSystem = { nixpkgs, localnixpkgs ? null, nixoscfg, system }:
    let
      importpath = if localnixpkgs != null then localnixpkgs else nixpkgs.pkgs;
      pkgs = import importpath {
        inherit system;
        inherit (machine.config.nixpkgs) config overlays;
      };

      # if we're not using a local git checkout, then we need to get the revShort
      # from our nixcfg/nixpkgs/<nixpkgs>/{default/metadata}.nix files
      extraModules =
        if localnixpkgs != null && builtins.pathExists localnixpkgs then [] else [
          ({config, ...}: {
            system.nixos.revision = nixpkgs.meta.revShort;
            system.nixos.versionSuffix = ".git.${nixpkgs.meta.revShort}";
          })
        ];
      machine = import "${nixpkgs.pkgs}/nixos/lib/eval-config.nix" {
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
