{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in minimalMkShell { # TODO use something else for system?
  name = "devtools";

  nativeBuildInputs = with pkgs; [
    (inputs.fenix.packages.${system}.latest.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])

    inputs.fenix.packages.${system}.rust-analyzer
    cargo-watch # TODO ??
    bacon # TODO ??
    rnix-lsp

    /*tools */ cmake pkg-config lldb python3
    /*nodejs*/ nodejs yarn
    /*golang*/ go go-outline gotools godef /*golint*/ gopls

    inputs.nix-eval-jobs.outputs.packages.${system}.default
    inputs.marksman.outputs.packages.${system}.default
  ];
}
