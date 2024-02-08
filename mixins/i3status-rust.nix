{
  pkgs,
  config,
  inputs,
  ...
}:

{
  config = {
    nixpkgs.overlays = [
      (
        final: prev:
        let
          nwPkgs = inputs.nixpkgs-wayland.packages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          inherit (nwPkgs) i3status-rust;
        }
      )
    ];

    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.libappindicator-gtk3 ];
        programs.i3status-rust = {
          enable = true;
          forceNewConfig = true;
          # bars = {
          #   "default" = {
          #     blocks = [

          #     ];
          #   };
          # };
        };
      };
  };
}
