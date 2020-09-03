{ pkgs, lib, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        steam
        steam-run
        #steam-run-native
      ];
    };
  };
}
