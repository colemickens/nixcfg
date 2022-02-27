{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        gopass
      ];

      xdg.configFile."gopass/config.yml".source = ./config.yml;
    };
  };
}
