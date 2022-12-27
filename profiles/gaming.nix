{ pkgs, config, ... }:

{
  config = {
    programs.steam.enable = true;
    environment.sessionVariables = {
      # STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/cole/.steam/root/compatibilitytools.d"
    };
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        evtest
        linuxConsoleTools

        gamehub
        vkbasalt
        gamescope
        protonup-ng
      ];
      programs.mangohud = {
        enable = true;
        # enableSessionWide = true;
        # settings = {};
      };
    };
  };
}
