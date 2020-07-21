{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      xdg.configFile."cachix/cachix.dhall".source = ./cachix.dhall;
    };
  };
}
