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
        #hostsFile = secrets."gh-hosts.yml".path;
        hostsFile = config.sops.secrets."cachix.dhall".path;
      };
    };
  };
}