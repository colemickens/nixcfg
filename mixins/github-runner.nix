{ config, pkgs, lib, ... }:


let
  runnerName = "${config.networking.hostName}-default";
in
{
  config = {
    sops.secrets = {
      "github-runner-token" = {
        owner = "cole";
        group = "cole";
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
      github-runners = {
        "${runnerName}" = {
          enable = true;
          url = "https://github.com/colemickens/nixcfg";
          tokenFile = config.sops.secrets."github-runner-token".path;
          replace = true;
          name = runnerName;
          extraLabels = [ runnerName ];
        };
      };
    };
  };
}
