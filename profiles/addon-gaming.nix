{ pkgs, config, inputs, ... }:

let
  # __yuzu = pkgs.yuzu-mainline;
  __yuzu = pkgs.yuzu-early-access;
  __yuzu1 = (__yuzu.override { qtwebengine = null; });
  _yuzu = __yuzu1.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [ "-DYUZU_USE_QT_WEB_ENGINE=OFF" ];
  });
in
{
  config = {
    boot.blacklistedKernelModules = [
      "hid-nintendo"
    ];
    networking.firewall = {
      # https://portforward.com/halo-infinite/
      allowedTCPPorts = [ 3074 ];
      allowedUDPPorts = [ 88 500 3074 2075 3544 4500 ];
    };
    services = {
      # replay-sorcery = {
      #   enable = true;
      #   enableSysAdminCapability = true;
      #   # autostart = {};
      #   # setting = {};
      # };
      # joycond = {
      #   enable = true;
      # };
    };
    programs = {
      steam = {
        enable = true;
      };
      gamescope = {
        enable = true;
        # enableRenice = true;
        # settings = {};
      };
      gamemode = {
        enable = true;
        enableRenice = true;
      };
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

        # inputs.jstest-gtk.packages.${stdenv.hostPlatform.system}.default
        # inputs.xboxdrv.packages.${stdenv.hostPlatform.system}.default

        # eh?
        # retroarchFull

        # emulators
        dolphin-emu # gamecube emu
        # mupen64plus
        # simple64-gui # TODO
        # ryujinx # switch emu
        _yuzu
        xemu

        airshipper
      ];
      programs = {
        mangohud = {
          enable = true;
        };
      };
    };
  };
}
