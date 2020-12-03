{ pkgs, ... }:

{
  config = {
    sops.secrets."cachix.dhall" = {
      owner = "cole";
      group = "cole";
      #path = "/home/cole/.config/cachix/cachix.dhall";
    };
    home-manager.users.cole = { pkgs, ... }: {
      # TODO: finish implementing a `gh` module
      programs.gh = {
        enable = true;
        #hostsFile = secrets."gh-hosts.yml".path;
        hostsFile = sops.secrets."cachix.dhall".path;
      };
    };
  };
}