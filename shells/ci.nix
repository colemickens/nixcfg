{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  llvmPackages = pkgs.llvmPackages_13;

in
minimalMkShell {
  name = "ci";

  # shellHook = ''
  #   # activate secrets?
  # '';

  nativeBuildInputs = with pkgs; [
    cachix
    bash
    curl
    cacert
    jq
    jless
    just
    parallel
    mercurial
    git
    nix-build-uncached
    nushell
  ];
}
