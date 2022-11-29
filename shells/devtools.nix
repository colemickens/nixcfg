{
  pkgs,
  inputs,
  ...
}: let
  minimalMkShell = import ./_minimal.nix {inherit pkgs;};
in
  minimalMkShell {
    name = "shell-devtools";

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

      fzf
      skim

      /*
      nix tools
      */
      nix
      rnix-lsp
      nil
      nixpkgs-fmt
      alejandra
      nix-du
      nix-tree

      /*
      tools
      */
      lldb
      /*
      nodejs
      */
      nodejs
      yarn
      /*
      golang
      */
      go
      go-outline
      gotools
      godef
      /*
      golint
      */
      gopls

      gron

      inputs.nix-eval-jobs.outputs.packages.${pkgs.hostPlatform.system}.default
      inputs.marksman.outputs.packages.${pkgs.hostPlatform.system}.default
    ];
  }
