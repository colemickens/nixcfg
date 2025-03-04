{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  runnerId = config.networking.hostName;
in
{
  imports = [
    inputs.nixos-github-actions.nixosModules.default
  ];

  config = {
    sops.secrets = {
      "github-runner-token" = {
        owner = "cole";
        group = "cole";
        mode = "0666";
        sopsFile = ../secrets/encrypted/github-runner-token;
        format = "binary";
      };
      # see mixins/git.nix for github-colebot-sshkey
      "cachix_signkey_colemickens" = {
        mode = "0666";
        sopsFile = ../secrets/encrypted/cachix_signkey_colemickens;
        format = "binary";
      };
    };
    services = {
      github-actions-runners = {
        "${runnerId}-default" = {
          enable = true;
          url = "https://github.com/colemickens/nixcfg";
          tokenFile = config.sops.secrets."github-runner-token".path;
          replace = true;
          extraLabels = [ "${runnerId}-default" ]; # TODO: remove runnerID?
        };
        # "${runnerId}-deployer1" = {
        #   enable = true;
        #   url = "https://github.com/colemickens/nixcfg";
        #   tokenFile = config.sops.secrets."github-runner-token".path;
        #   replace = true;
        #   extraLabels = [ "${runnerId}-deployer" ];
        # };
        # "${runnerId}-deployer2" = {
        #   enable = true;
        #   url = "https://github.com/colemickens/nixcfg";
        #   tokenFile = config.sops.secrets."github-runner-token".path;
        #   replace = true;
        #   extraLabels = [ "${runnerId}-deployer" ];
        # };
        # "${runnerId}-deployer3" = {
        #   enable = true;
        #   url = "https://github.com/colemickens/nixcfg";
        #   tokenFile = config.sops.secrets."github-runner-token".path;
        #   replace = true;
        #   extraLabels = [ "${runnerId}-deployer" ];
        # };
      };
    };
  };
}
