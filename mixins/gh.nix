{ pkgs, config, ... }:

{
  config = {
    sops.secrets."gh-hosts.yml" = {
      owner = "cole";
      group = "cole";
      path = "/home/cole/.config/gh/hosts.yml";
      sopsFile = ../secrets/encrypted/gh-hosts.yml;
      format = "binary";
    };
    home-manager.users.cole = { pkgs, ... }: {
      programs.gh = {
        enable = true;
      };
    };
  };
}