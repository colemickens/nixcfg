{ pkgs, ... }:

{
  config = {
    boot.kernelModules = [ "ntsync" ];
    networking.firewall = {
      # https://portforward.com/halo-infinite/
      allowedTCPPorts = [ 3074 ];
      allowedUDPPorts = [
        88
        500
        3074
        2075
        3544
        4500
      ];
    };
    hardware.graphics.extraPackages = [ pkgs.gamescope ];
    # security.wrappers = {
    #   xemu = {
    #     owner = "root";
    #     group = "root";
    #     source = "${pkgs.xemu}/bin/xemu";
    #     capabilities = "cap_net_raw,cap_net_admin=eip";
    #   };
    # };
    programs = {
      steam = {
        enable = true;
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
    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        home.packages = with pkgs; [
          evtest # misc input debug
          linuxConsoleTools # joystick testing

          protonplus

          vkbasalt
          goverlay
          # vkpost # ??
          heroic

          legendary-gl
        ];
        programs = {
          mangohud = {
            enable = true;
          };
        };
      };
  };
}
