{ pkgs, config, inputs, ... }:

let
  registrationName = "cole-mickens";
  registrationRepo = "https://github.com/${registrationName}";
in {
  config = {
    sops.secrets."gha-token-${config.networking.hostName}" = {
      #owner = "github-runner";
      #group = "github-runner";
      path = "/var/lib/github-runner/${registrationName}/.token";
    };

    services.github-runner = {
      enable = true;

      url = "https://github.com/${registrationName}";
      name = config.networking.hostName;
      replace = true;
      tokenFile = config.sops.secrets."gha-token-${config.networking.hostName}".path;

      # TODO: seems reasonable to maybe provide vault? (or just use nix for it?)
      # extraPackages = with pkgs; [ vault ];
    };
  };
}
