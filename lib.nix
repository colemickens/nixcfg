{
  # overlay will load an overlay, either from:
  #  ../overlays/{name}
  #  ./pkgs/{name}
  findImport = type: name:
    let
      localimportpath = ./.. + "/${type}/${name}";
      importpath = ./.imports + "/${type}/${name}";
    in
      assert (!(builtins.hasAttr "getFlake" builtins));
      if builtins.pathExists localimportpath then
        localimportpath
      else if builtins.pathExists importpath then
        (import importpath)
      else (abort "you must vendor all imports");

  # TODO: see if there's way to simplify this, (note: nixpkgs.nixos does not eval overlays)
  mkSystem = { nixpkgs, system ? "x86_64-linux", rev ? "git", extraModules ? [], ... }:
    let
      pkgs = import (nixpkgs) {
        inherit (machine.config.nixpkgs) config overlays;
      };
      machine = import "${nixpkgs}/nixos/lib/eval-config.nix" {
        inherit system;
        modules = [
          #({config, ...}: {
          #  system.nixos.revision = rev;
          #  system.nixos.versionSuffix = ".git.${rev}";
          #})
        ] ++ extraModules;
        specialArgs = { isFlakes = false; };
      };
    in
      machine;
}
