{ pkgs, config, inputs, ... }:

let
  # yuzu_noQtWeb =
  #   (pkgs.yuzuPackages.early-access.override { qtwebengine = null; }).overrideAttrs (old: {
  #     cmakeFlags = old.cmakeFlags ++ [ "-DYUZU_USE_QT_WEB_ENGINE=OFF" ];
  #   });

  # yuzu_noQtWeb2 =
  #   (pkgs.yuzuPackages.early-access.override { qtwebengine = null; }).overrideAttrs (old: {
  #     cmakeFlags = old.cmakeFlags ++ [ "-DYUZU_USE_QT_WEB_ENGINE=OFF" ];
  #   });

  # _yuzu = yuzu_noQtWeb;
  # _yuzu = yuzu_noQtWeb2;
  _yuzu = pkgs.yuzuPackages.early-access;

  vkdevice = "1002:73ef";
in
{
  config = {
    networking.firewall = {
      # https://portforward.com/halo-infinite/
      allowedTCPPorts = [ 3074 ];
      allowedUDPPorts = [ 88 500 3074 2075 3544 4500 ];
    };
    hardware.opengl.extraPackages = [ pkgs.gamescope ];
    hardware.opengl.driSupport32Bit = true;
    programs = {
      steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
          env = {
            WLR_RENDERER = "vulkan";
            DXVK_HDR = "1";
            ENABLE_GAMESCOPE_WSI = "1";
            WINE_FULLSCREEN_FSR = "1";
          };
          args = [
            "--hdr-enabled"
            "--output-width"
            "1920"
            "--output-height"
            "1080"
            "--adaptive-sync"
            "--steam"
            "--hdr-enabled"
            "--hdr-itm-enable"
            "--prefer-output"
            "HDMI-A-1"
            "--prefer-vk-device"
            vkdevice
          ];
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
        # _yuzu
        xemu

        airshipper

        # okay, gotta see what these crazy kids are building...
        # TODO: check out vinegar whenever it ... gets merged into nixpkgs
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
