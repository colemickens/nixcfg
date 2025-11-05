{ pkgs, config, ... }:

let
  nixclean = (
    pkgs.writeShellScriptBin "nixclean" ''
      nix-env --profile ~/.local/state/nix/profiles/home-manager --delete-generations +1
      sudo nix-collect-garbage -d
      sudo nix-collect-garbage
    ''
  );
in
{
  config = {
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "cole-custom-commands";
        paths = [
          nixclean
        ];
      })
    ];
  };
}
