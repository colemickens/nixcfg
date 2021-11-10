{ config, pkgs, lib, ... }:

let
  useNvidiaWayland = true;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;

  nvidia-sway = (pkgs.writeShellScriptBin "nvidia-sway" ''
    env WLR_NO_HARDWARE_CURSORS=1 \
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
      # patches = (old.patches or []) ++ [
      #   ../misc/wlroots-gbm.patch
      # ];
    });
    #
    # UNRELEASED:
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
    libglvnd = prev.libglvnd.overrideAttrs (old: rec {
      version = "1.3.4.99";
      src = prev.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "glvnd";
        repo = "libglvnd";
        rev = "2d69d4720c56d2d8ab1f81eff62eecd069f14c62"; # Oct 28 2021
        sha256 = "sha256-137gLX7LgfOBNnci9rnp4fg194m3ieY2q9HuRhQdb1Y=";
      };
    });
    #
    # ALREADY UPSTREAM:
    libdrm = prev.libdrm.overrideAttrs (old: rec {
      version = "2.4.108";
      src = prev.fetchurl {
        url = "https://dri.freedesktop.org/libdrm/libdrm-${version}.tar.xz";
        sha256 = "186nwf7qnzh805iz8k3djq3pd1m79mgfnjsbw7yn6rskpj699mx1";
      };
    });
    xwayland = prev.xwayland.overrideAttrs (old: rec {
      version = "21.1.3";
      src = prev.fetchurl {
        url = "mirror://xorg/individual/xserver/xwayland-${version}.tar.xz";
        sha256 = "sha256-68J1fzn9TH2xZU/YZZFYnCEaogFy1DpU93rlZ87b+KI=";
      };
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
