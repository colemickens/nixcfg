{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./desktop-sway.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      drm_info
    ];

    nixpkgs.overlays =  [
      inputs.nixpkgs-wayland.overlay-egl
    ];
  };
}
