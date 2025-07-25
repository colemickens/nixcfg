{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    ./gui.nix
  ];
  config = {
    programs = {
      wshowkeys.enable = true;
    };

    services.input-remapper.enable = true;
    programs.ydotool = {
      enable = true;
      group = "ydotool";
    };

    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.sessionVariables = {
          XDG_SESSION_TYPE = "wayland";
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
        };

        home.packages = with pkgs; [
          qt5.qtwayland
          qt6.qtwayland

          gradia

          oculante # image viewer (rust)
          slurp # area selection
          wl-clipboard # wl-{copy,paste}
          wf-recorder # screen record
          wl-screenrec # screen record (vaapi + rust)
          wev # event viewer
          wtype # virtual keystroke insertion

          wl-gammarelay-rs
        ];
      };
  };
}
