{ config, lib, pkgs, ... }:

{
  config = {
    nixpkgs.overlays = [
      (final: prev:
        {
          sway-unwrapped = prev.sway-unwrapped.override({ wlroots = pkgs.wlroots-eglstreams; });
        }
      )
    ];
  };
}
