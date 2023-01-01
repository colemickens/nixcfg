{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix

    # ../mixins/ironbar.nix
    ../mixins/kanshi.nix
    ../mixins/mako.nix
    ../mixins/obs.nix
    ../mixins/sirula.nix
    ../mixins/waybar.nix
    # ../../mixins/wlsunset.nix
    ../../mixins/wluma.nix
  ];
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      services = {
        # poweralertd.enable = true;
      };
      home.sessionVariables = {
        XDG_SESSION_TYPE = "wayland";
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
      home.packages = with pkgs; [
        # wayland env requirements
        qt5.qtwayland
        qt6.qtwayland

        # wayland adjacent
        sirula # launcher
        wayout # display on/off
        wl-clipboard # wl-{copy,paste}
        wtype # virtual keystroke insertion

        # misc utils
        # imv
        oculante
        grim
        slurp
      ];
    };
  };
}
