{ pkgs, config, ... }:

{
  config = {
    programs.steam.enable = true;
    hardware = {
      xone.enable = true;
    };
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        evtest
        linuxConsoleTools

        vkbasalt
        gamescope
        protonup-ng

        yuzu-mainline
        ryujinx
      ];
      programs.mangohud = {
        enable = true;
      };
    };
  };
}
