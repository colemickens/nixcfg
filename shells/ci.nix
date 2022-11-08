{ pkgs }:

let
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };
in
minimalMkShell {
  name = "ci";

  # shellHook = ''
  #   # activate secrets?
  # '';

  nativeBuildInputs = (
    (with pkgs; [
      cachix
      cacert
      du-dust
      git
      gh
      mercurial
      nushell
    ]) ++ [
      inputs.nix-eval-jobs.outputs.packages.${system}.default
    ]
  );
}
