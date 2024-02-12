{ pkgs, inputs, ... }:

# expects:
# - sops-nix: .age-key.txt to be in place

let
  ciusername = "runner";
in
{
  imports = [ inputs.sops-nix.outputs.homeManagerModules.sops ];
  # nixpkgs = {
  #   config = {
  #     inherit system;
  #   };
  # };
  home = {
    extraOutputsToInstall = [
      "info"
      "man"
      "share"
      "icons"
      "doc"
    ];
    stateVersion = "22.11";
    username = ciusername;
    homeDirectory = "/home/${ciusername}";
  };

  manual = {
    manpages.enable = false;
  };
  news.display = "silent";
  home.packages = (
    (with pkgs; [
      cacert
      cachix
      dust
      mercurial
      nixpkgs-fmt
      nushell
    ])
    ++ [
      inputs.nix-eval-jobs.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.nix-update.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
  );
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userEmail = "cole.mickens+colebot@gmail.com";
      userName = "Colebot";
    };
    ssh = {
      userKnownHostsFile = "~/.ssh/known_hosts ${../hosts/known_hosts}";
    };
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
        sopsFile = ../secrets/ci/encrypted/cachix_signing_key;
        format = "binary";
        path = "/home/${ciusername}/.cachix_signing_key";
      };
      "tailscale_authkey" = {
        sopsFile = ../secrets/ci/encrypted/tailscale_authkey;
        format = "binary";
        path = "/home/${ciusername}/.tailscale_authkey";
      };
    };
    age = {
      keyFile = "/home/${ciusername}/.age-key.txt";
    };
  };
}
