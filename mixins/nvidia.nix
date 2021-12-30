{ config, pkgs, lib, ... }:

let
  useNvidiaWayland = true;
  wlrootsPatchForNvidia = true;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;

  extraEnv = { WLR_NO_HARDWARE_CURSORS = "1"; };
  nvidia-wlroots-overlay = (final: prev: {
    wlroots = prev.wlroots.overrideAttrs(old: {
      # HACK: https://forums.developer.nvidia.com/t/nvidia-495-does-not-advertise-ar24-xr24-as-shm-formats-as-required-by-wayland-wlroots/194651
      #patches = (old.patches or []) ++ ( [../misc/wlroots.patch] );
      postPatch = if !wlrootsPatchForNvidia then null else ''
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
    home-manager.users.cole = { pkgs, ... }: {
      wayland.windowManager.sway = {
        extraOptions = [ "--unsupported-gpu" ];
      };
    };
    environment.variables = extraEnv;
    environment.sessionVariables = extraEnv;

    nixpkgs.overlays = [ nvidia-wlroots-overlay ];
    environment.systemPackages = with pkgs; [
      #mesa-demos
      glxinfo
      vulkan-tools
      glmark2
    ];

    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidiaPackage;
    hardware.nvidia.powerManagement.enable = false;

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = useNvidiaWayland;
      displayManager.gdm.nvidiaWayland = useNvidiaWayland;
    };
  };
}
