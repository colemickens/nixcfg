{ pkgs, ... }:

# expects:
# - sops-nix: .age-key.txt to be in place

let
  ciusername = "runner";
in
{
  # nixpkgs = {
  #   config = {
  #     inherit system;
  #   };
  # };
  home = {
    extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
    stateVersion = "22.11";
    username = ciusername;
    homeDirectory = "/home/${ciusername}";
  };

  manual = { manpages.enable = false; };
  news.display = "silent";
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };
  # enable git, ssh, configs
  # grm?
  sops = {
    secrets = {
      "id_rsa_hydra_runner" = {
        sopsFile = ../secrets/ci/encrypted/id_rsa_hydra;
        format = "binary";
        path = "/home/${ciusername}/.ssh/id_rsa";
      };
      "cachix_signing_key" = {
        sopsFile = ../secrets/ci/encrypted/cachix_dhall_colemickens;
        format = "binary";
        path = "/home/${ciusername}/.config/cachix/cachix.dhall";
      };
    };
    age = {
      keyFile = "/home/${ciusername}/.age-key.txt";
    };
  };
}
