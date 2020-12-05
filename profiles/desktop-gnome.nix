{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix
  ];
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome3.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        #MOZ_ENABLE_WAYLAND = "1";
        MOZ_USE_XINPUT2 = "1";

        #SDL_VIDEODRIVER = "wayland";
        #QT_QPA_PLATFORM = "wayland";
        #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        #_JAVA_AWT_WM_NONREPARENTING = "1";

        #XDG_SESSION_TYPE = "wayland";
      };
      home.packages = with pkgs; [
        # sway-related
        gnome3.gnome-tweaks
      ];
    };
  };
}
