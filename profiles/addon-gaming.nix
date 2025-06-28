{ pkgs, ... }:

{
  config = {
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

          # jesus christ
          # protonup-ng doesn't do the rigth thing and is abandoned
          # i'm not about to try to deal with switching/packaging protonup
          # proton-rs looks over-engineered and is _also_ broken
          # so, wtf, I guess qt gets a turn
          protonup-qt

          vkbasalt
          goverlay

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
