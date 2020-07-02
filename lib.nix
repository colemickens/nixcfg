{
  # overlay will load an overlay, either from:
  #  ../overlays/{name}
  #  ./pkgs/{name}
  findImport = path:
    let
      localimportsAllowed = ((builtins.getEnv "NIXPKGS_LOCAL_IMPORTS_ALLOWED") == "true");
      localimportpath = ./.. + "/${path}";
      importpath = ./.imports + "/${path}";
    in
      assert (!(builtins.hasAttr "getFlake" builtins));
      if (localimportsAllowed && builtins.pathExists localimportpath) then
        localimportpath
      else if builtins.pathExists importpath then
        (import importpath)
      else (abort "you must vendor all imports: ${path}");

  mkSystem = { nixpkgs, system ? "x86_64-linux", rev ? "git", extraModules ? [], ... }:
    let
      machine = import "${nixpkgs}/nixos/lib/eval-config.nix" {
        inherit system;
        modules = [
          ({config, ...}: {
            system.nixos.revision = "git";
            system.nixos.versionSuffix = ".git";
          })
        ] ++ extraModules;
        specialArgs = { inputs = null; };
      };
    in
      machine;
}
