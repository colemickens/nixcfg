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

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs = {
    htop.enable = true;
  };

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
      jujutsu
      gnupg
      bitwarden-cli
      fd
    ]
    ++ lib.optionals stdenv.isDarwin [
      m-cli # useful macOS CLI commands
    ];
}
