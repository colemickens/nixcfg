{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
minimalMkShell {
  name = "ci";

  # shellHook = ''
  #   # activate secrets?
  # '';

  nativeBuildInputs = with pkgs; [
    cachix
    cacert
    jless
    mercurial
    git
    gh
    nushell
    inputs.nix-eval-jobs.outputs.packages.${system}.default
  ];
}
