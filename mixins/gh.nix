{ pkgs, config, ... }:

{
  config = {
    sops.secrets."gh-hosts.yml" = {
      owner = "cole";
      group = "cole";
    };
    home-manager.users.cole = { pkgs, ... }: {
      programs.gh = {
        enable = true;
      };
      xdg.configFile."gh/hosts.yml".path = config.sops.secrets."gh-hosts.yml".path;
    };
  };
}