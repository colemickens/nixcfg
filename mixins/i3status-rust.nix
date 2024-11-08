{
  pkgs,
  config,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.libappindicator-gtk3 ];
        programs.i3status-rust = {
          enable = true;
          forceNewConfig = true;
          # bars = {
          #   "default" = {
          #     blocks = [

          #     ];
          #   };
          # };
        };
      };
  };
}
