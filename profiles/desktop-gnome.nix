{ pkgs, lib, config, inputs, ... }:

let 
  useNvidiaWayland = true;
in
{
  imports = [
    ./gui.nix
  ];
  config = {
    nixpkgs.config.firefox.enableGnomeExtensions = true;
    
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland.enable = useNvidiaWayland;
    services.xserver.displayManager.gdm.nvidiaWayland.enable = useNvidiaWayland;
    services.xserver.desktopManager.gnome.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";

        #SDL_VIDEODRIVER = "wayland";
        #QT_QPA_PLATFORM = "wayland";
        #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        #_JAVA_AWT_WM_NONREPARENTING = "1";

        #XDG_SESSION_TYPE = "wayland";
      };
      home.packages = with pkgs; [
        gnome3.gnome-tweaks
      ];
    };
  };
}
