{ config, ... }:

let
  runnerName = "${config.networking.hostName}-default";
in
{
  config = {
    sops.secrets = {
      "github-runner-token" = {
        owner = "cole";
        group = "cole";
        mode = "0666";
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
          workDir = "/var/lib/github-runner/${runnerName}"; # TODO: make sure this works
          extraLabels = [ runnerName ];
        };
      };
    };
  };
}
