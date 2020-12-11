{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./desktop-sway.nix
  ];
  config = {
    nixpkgs.overlays =  [
      inputs.nixpkgs-wayland.overlay
    ];
  };
}
