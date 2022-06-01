{ pkgs, lib, config, inputs, ... }:

let
  prefs = import ../../mixins/_preferences.nix { inherit pkgs lib config inputs; };
  useUnstableOverlay = true;
in {
  imports = [
    ../../profiles/interactive.nix # common, hm, etc
    ../../mixins/gtk.nix

    ../../mixins/fonts.nix
    ../../mixins/pipewire.nix # snapcast
    ../../mixins/snapclient-local.nix # snapcast
    ../../mixins/snapviz.nix
    ../../mixins/spotify.nix
    ../../mixins/wayland-tweaks.nix
  ];
  config = {
    nixpkgs.overlays = if useUnstableOverlay then [
      inputs.nixpkgs-wayland.overlay
    ] else [];

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        TERMINAL = prefs.default_term;
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
      };
      home.packages = with pkgs; [
      ];
    };
  };
}
