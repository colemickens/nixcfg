{ pkgs, inputs, ... }:

let
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };
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
