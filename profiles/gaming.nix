{ pkgs, lib, config, inputs, ... }:

{
  config = {
    hardware = {
      opengl = {
        driSupport32Bit = (pkgs.system=="x86_64-linux");
      };
    };
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        steam
        steam-run
        #steam-run-native
      ];
    };
  };
}
