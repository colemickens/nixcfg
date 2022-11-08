{ pkgs, inputs, ... }:

let
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };
in
minimalMkShell {
  name = "devtools";

  nativeBuildInputs = with pkgs; [
    (inputs.fenix.packages.${pkgs.hostPlatform.system}.latest.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])

    inputs.fenix.packages.${pkgs.hostPlatform.system}.rust-analyzer
    bacon # TODO ??

    /* nix tools */
    nix
    rnix-lsp

    /*tools */
    lldb
    /*nodejs*/
    nodejs
    yarn
    /*golang*/
    go
    go-outline
    gotools
    godef /*golint*/
    gopls

    inputs.nix-eval-jobs.outputs.packages.${pkgs.hostPlatform.system}.default
    inputs.marksman.outputs.packages.${pkgs.hostPlatform.system}.default
  ];
}
