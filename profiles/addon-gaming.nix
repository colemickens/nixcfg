{ pkgs, config, ... }:

{
  config = {
    networking.firewall = {
      # https://portforward.com/halo-infinite/
      allowedTCPPorts = [ 3074 ];
      allowedUDPPorts = [ 88 500 3074 2075 3544 4500 ];
    };
    programs.steam.enable = true;
    # programs.gamescope = {
    #   enable = true;
    #   # settings = {};
    # };
    hardware = {
      xone.enable = true;
    };
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        evtest
        linuxConsoleTools

        # vkbasalt
        goverlay
        gamescope
        protonup-ng

        yuzu-mainline
        ryujinx
      ];
      # programs.mangohud = {
      #   enable = true;
      # };
    };
  };
}
