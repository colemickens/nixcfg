{ pkgs, config, ... }:

{
  config = {
    programs.steam.enable = true;
    programs.gamescope = {
      enable = true;
      # settings = {};
    };
    hardware = {
      xone.enable = true;
    };
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        evtest
        linuxConsoleTools

        vkbasalt
        goverlay
        # gamescope
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
