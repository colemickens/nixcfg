{ config, pkgs, lib, ... }:

let
  useNvidiaWayland = false;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.beta;

  nvidia-sway = (pkgs.writeShellScriptBin "nvidia-sway" ''
    env \
      GBM_BACKEND=nvidia-drm \
      __GLX_VENDOR_LIBRARY_NAME=nvidia \
      WLR_NO_HARDWARE_CURSORS=1 \
        sway --unsupported-gpu -d &>/tmp/sway.log
  '');
  nvidia-wlroots-overlay = (final: prev: {
    wlroots = prev.wlroots.overrideAttrs(old: {
      postPatch = ''
        sed -i 's/assert(argb8888 &&/assert(true || argb8888 ||/g' 'render/wlr_renderer.c'
      '';
    });
  });
in
{
  imports = if useNvidiaWayland then [
    ./wayland-tweaks.nix
  ] else [];

  config = {
    nixpkgs.overlays = [ nvidia-wlroots-overlay ];
    environment.systemPackages = with pkgs; [
      mesa-demos
      vulkan-tools
      nvidia-sway
    ];

    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidiaPackage;
    hardware.nvidia.powerManagement.enable = false;

    # TODO: implement and add to existing PR:
    # kind of a weird place to put this option
    # hardware.nvidia.useUpstreamEglWayland = true;

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = useNvidiaWayland;
      displayManager.gdm.nvidiaWayland = useNvidiaWayland;
    };
  };
}
