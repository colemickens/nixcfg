{ pkgs, config, ... }:

let
  _yuzu = pkgs.yuzu-mainline.override { qtwebengine = null; };
in
{
  config = {
    networking.firewall = {
      # https://portforward.com/halo-infinite/
      allowedTCPPorts = [ 3074 ];
      allowedUDPPorts = [ 88 500 3074 2075 3544 4500 ];
    };
    services = {
      replay-sorcery = {
        enable = true;
        enableSysAdminCapability = true;
        # autostart = {};
        # setting = {};
      };
    };
    programs = {
      steam = {
        enable = true;
      };
      gamescope = {
        enable = true;
        enableRenice = true;
        # settings = {};
      };
      gamemode = {
        enable = true;
        enableRenice = true;
      };
    };
    hardware = {
      xone.enable = true; # xbox one wired/wireless driver
    };
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        evtest # misc input debug
        linuxConsoleTools # joystick testing
        protonup-ng # latest and greatest proton

        vkbasalt
        goverlay

        # emulators
        dolphin-emu # gamecube emu
        ryujinx # switch emu
        _yuzu
      ];
      programs = {
        mangohud = {
          enable = true;
        };
      };
    };
  };
}
