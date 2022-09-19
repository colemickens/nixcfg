{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  llvmPackages = pkgs.llvmPackages_13;

in
minimalMkShell pkgs.system {
  # TODO use something else for system?
  name = "devshell";
  hardeningDisable = [ "fortify" ];

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
  RUST_BACKTRACE = 1;

  nativeBuildInputs = with pkgs; [
    #nixUnstable
    cachix
    nixpkgs-fmt
    nix-prefetch-git
    bash
    curl
    cacert
    jq
    jless
    just
    parallel
    mercurial
    git
    # todo: move a bunch of these to 'apps#update-env' ?
    nettools
    openssh
    ripgrep
    rsync
    sops
    gh
    gawk
    gnused
    gnugrep
    inputs.nickel.packages.${system}.build
    OVMF.fd
    # not sure, would be nice for nix stuff to work in helix even if I forget to join the shell
    rnix-lsp
    nixpkgs-fmt
  ];
}
