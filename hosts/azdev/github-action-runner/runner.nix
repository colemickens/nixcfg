{ pkgs, config, inputs, ... }:

{
  config = {
    sops.secrets."gha-token" = {
      owner = "github-runner";
      group = "github-runner";
      path = "/var/lib/github-runner/nixcfg/.token";
    };

    services.github-runner = {
      enable = true;

      url = "https://github.com/colemickens/nixcfg";
      name = "azdev";
      replace = true;
      tokenFile = config.sops.secrets."gha-token".path;

      # TODO: seems reasonable to maybe provide vault? (or just use nix for it?)
      # extraPackages = with pkgs; [ vault ];
    };
  };
}