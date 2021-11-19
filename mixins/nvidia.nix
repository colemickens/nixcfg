{ config, pkgs, lib, ... }:

let
  useNvidiaWayland = true;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;

  nvidia-sway = (pkgs.writeShellScriptBin "nvidia-sway" ''
    echo "GBM_BACKENDS_PATH can be dropped soon!"
    echo "check: https://nixpk.gs/pr-tracker.html?pr=145319"
    sleep 10
    env \
      WLR_NO_HARDWARE_CURSORS=1 \
      GBM_BACKENDS_PATH=/run/opengl-driver/lib/gbm \
      sway --unsupported-gpu --debug \
        &>$HOME/nvidia-sway.log
  '');
  nvidia-wlroots-overlay = (final: prev: {
    # HACK:
    # https://forums.developer.nvidia.com/t/nvidia-495-does-not-advertise-ar24-xr24-as-shm-formats-as-required-by-wayland-wlroots/194651
    wlroots = prev.wlroots.overrideAttrs(old: {
      postPatch = ''
        sed -i 's/assert(argb8888 &&/assert(true || argb8888 ||/g' 'render/wlr_renderer.c'
      '';
    });
    #
    # UNRELEASED: (barely anything after 1.1.9, but 1.1.9 itself might help... with... xwayland scenario?)
    egl-wayland = prev.egl-wayland.overrideAttrs (old: rec {
      version = "1.1.9.99";
      src = prev.fetchFromGitHub {
        owner = "NVIDIA";
        repo = "egl-wayland";
        rev = "daab8546eca8428543a4d958a2c53fc747f70672"; # Oct 29 2021
        sha256 = "sha256-IrLeqBW74mzo2OOd5GzUPDcqaxrsoJABwYyuKTGtPsw=";
      };
      buildInputs = old.buildInputs ++ [ prev.wayland-protocols ];
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
      glmark2
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
