{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  _nvtop = pkgs.nvtop.override { nvidia = false; };
in
{
  config = {
    hardware.graphics.enable = true;
    nixpkgs.overlays = [
      (final: prev: {
        mesa = prev.mesa.override {
          galliumDrivers = [
            "zink"
            "swrast"
          ];
          vulkanDrivers = [
            "imagination-experimental"
            "swrast"
          ];
        };
        eglPlatforms = [ "wayland" ];
      })
    ];
  };
}
