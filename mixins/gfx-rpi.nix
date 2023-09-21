{ pkgs, lib, config, inputs, ... }:

let
in
{
  imports = [
    ./gfx-debug.nix
  ];
  config = {
    system.build.visualizer2Pkg = pkgs.visualizer2;
    system.build.mesaPkg = pkgs.mesa;
    nixpkgs.overlays = [
      (final: prev: {
        mesa = (prev.mesa.override {
          eglPlatforms = [
            "x11"
            "wayland"
          ];
          galliumDrivers = [
            "swrast"
            "virgl"
            "kmsro" # cargo culted?
            "vc4" # rpi
            "v3d"
            "zink"
          ];
          vulkanDrivers = [
            "swrast"
            "broadcom"
          ];
          vulkanLayers = [
            "device-select"
          ];
        });
      })
    ];
    environment.systemPackages = with pkgs; [
      libva-utils
      vulkan-tools
      vulkan-loader
      vulkan-headers
      # drm_info
    ];
    hardware = {
      opengl = {
        enable = true;
        # extraPackages = [
        #   pkgs.vulkan-validation-layers
        # ];
      };
    };
  };
}
