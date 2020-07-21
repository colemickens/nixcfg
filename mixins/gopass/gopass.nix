{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      xdg.configFile."gopass/config.yml".source = ./config.yml;
    };
  };
}
