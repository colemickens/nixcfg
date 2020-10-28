{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      # TODO: finish implementing a `gh` module
      programs.gh = {
        enable = true;
        hostsFile = secrets."gh-hosts.yml".path;
      };
    };
  };
}