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
      xone.enable = true; # xbox one wired/wireless driver
    };
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        evtest # misc input debug
        linuxConsoleTools # joystick testing
        protonup-ng # latest and greatest proton

        # vkbasalt
        # goverlay
        gamescope

        # emulators
        dolphin-emu # gamecube emu
        ryujinx # switch emu
        yuzu-mainline # switch emu
      ];
      # programs.mangohud = {
      #   enable = true;
      # };
    };
  };
}
