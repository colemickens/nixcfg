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

    ../mixins/obs.nix
    ../mixins/sirula.nix
  ];
  config = {
    nixpkgs.overlays = [
      (
        final: prev:
        let
          nwPkgs = inputs.nixpkgs-wayland.packages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          inherit (nwPkgs) drm_info;
        }
      )
    ];

    programs = {
      wshowkeys.enable = true;
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

          drm_info

          oculante # image viewer (rust)
          grim # area selection
          slurp # screen capture
          way-displays # wayland output management
          wl-clipboard # wl-{copy,paste}
          wf-recorder # screen record
          wl-screenrec # screen record (vaapi + rust)
          wlay # Graphical output management for Wayland.
          wev # event viewer
          wtype # virtual keystroke insertion

          inputs.nixpkgs-wayland.outputs.packages.${pkgs.stdenv.hostPlatform.system}.wl-gammarelay-rs
        ];
      };
  };
}
