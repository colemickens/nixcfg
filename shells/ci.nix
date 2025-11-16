{ pkgs, inputs, ... }:

let
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };
in
minimalMkShell {
  name = "shell-ci";

  # shellHook = ''
  #   # activate secrets?
  # '';

  nativeBuildInputs = (
    with pkgs;
    [
      cacert
      dust
      git
      mercurial
      nushell
      openssh

      nixfmt
    ]
  );
}
