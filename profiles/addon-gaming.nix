{ pkgs, config, inputs, ... }:

let
  yuzu_noQtWeb =
    (pkgs.yuzu-early-access.override { qtwebengine = null; }).overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ [ "-DYUZU_USE_QT_WEB_ENGINE=OFF" ];
    });
in
{
  config = {
    networking.firewall = {
      # https://portforward.com/halo-infinite/
      allowedTCPPorts = [ 3074 ];
      allowedUDPPorts = [ 88 500 3074 2075 3544 4500 ];
    };
    hardware.opengl.extraPackages = [ pkgs.gamescope ];
    programs = {
      steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
          args = [ "--hdr-enabled" ];
        };
      };
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      # gamemode = {
      #   enable = true;
      #   enableRenice = true;
      # };
    };
    hardware = {
      # xone.enable = true; # xbox one wired/wireless driver
      # xpad-tip.enable = true; # xpad-override
      # TODO: fork? test? try with regular xbox controller
      # xboxdrv.enable = true; # userspace xbox driver
    };
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        evtest # misc input debug
        linuxConsoleTools # joystick testing
        protonup-ng # latest and greatest proton

        vkbasalt
        goverlay

        dolphin-emu # gamecube emu
        yuzu_noQtWeb
        xemu

        airshipper

        # okay, gotta see what these crazy kids are building...
        grapejuice
      ];
      programs = {
        mangohud = {
          enable = true;
        };
      };
    };
  };
}
