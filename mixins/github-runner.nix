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
    };
    services = {
      github-runners = {
        "${runnerName}" = {
          enable = true;
          url = "https://github.com/colemickens/nixcfg";
          tokenFile = config.sops.secrets."github-runner-token".path;
          replace = true;
          name = runnerName;
        };
      };
    };
  };
}
