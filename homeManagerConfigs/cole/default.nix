{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.stateVersion = "25.05";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages =
    with pkgs;
    [
      coreutils
      curl
      wget
      zellij
      jq
      ripgrep
      prs
      gnupg
      fd
      restic
      sops
    ]
    ++ lib.optionals stdenv.isDarwin [
      m-cli # useful macOS CLI commands
    ];
}
