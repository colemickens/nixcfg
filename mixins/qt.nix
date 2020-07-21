{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {  
      qt = {
        enable = true;
        platformTheme = "gtk";
      };
    };
  };
}
