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
    (with pkgs; [
      cachix
      cacert
      du-dust
      git
      gh
      mercurial
      nushell
      sd
    ]) ++ [
      inputs.nix-eval-jobs.outputs.packages.${pkgs.hostPlatform.system}.default
    ]
  );
}
