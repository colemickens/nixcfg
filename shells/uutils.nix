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
    # (pkgs.runCommand "sleep" { } ''
    #   ${pkgs.coreutils}/bin/sleep 11
    #   echo "out" >$out
    # '')
  ];
}
