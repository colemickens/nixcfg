{ config, lib, pkgs, inputs, ... }:

with lib;

{
  environment.enableDebugInfo = true;
  nixpkgs.overlays = [
    (final: prev: {
      xdg-desktop-portal = prev.enableDebugging prev.xdg-desktop-portal;
      xdg-desktop-portal-gtk = prev.enableDebugging prev.xdg-desktop-portal-gtk;
      xdg-desktop-portal-wlroots = prev.enableDebugging prev.xdg-desktop-portal-wlroots;
    })
  ];
}
