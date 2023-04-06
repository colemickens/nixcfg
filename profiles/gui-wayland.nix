{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix

    ../mixins/obs.nix
    ../mixins/sirula.nix
    ../mixins/wluma.nix
  ];
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        XDG_SESSION_TYPE = "wayland";
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
      home.packages = with pkgs; [
        qt5.qtwayland
        qt6.qtwayland

        wl-clipboard # wl-{copy,paste}
        wtype # virtual keystroke insertion

        # imv # image viewer
        oculante # image viewer (rust)
        grim # area selection
        slurp # screen capture
        wf-recorder # screen record
        wev # event viewer

        # wayout # https://git.sr.ht/~shinyzenith/wayout (disp power mgmt)
        # wayout # https://git.sr.ht/~proycon/wayout (draw text to surface)
      ];
    };
  };
}
