{ inputs, system
, minimalMkShell
, ... }:

let
  # pkgs = import inputs.nixpkgs {
  #   inherit system;
  #   overlays = [
  #     (prev: final: {
  #       coreutils = prev.uutils-coreutils.override { prefix = ""; };
  #     })
  #   ];
  # };
  # minimalMkShell = import ../lib/minimalMkShell.nix { inherit pkgs; };
  pkgs = import inputs.nixpkgs { inherit system; };
in
minimalMkShell {
  name = "uutils";

  shellHook = ''
    ${pkgs.nushell}/bin/nu
  '';
  
  nativeBuildInputs = with pkgs; [
    (uutils-coreutils.override { prefix = ""; })
  ];
}
