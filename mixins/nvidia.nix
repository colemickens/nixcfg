{ config, pkgs, lib, ... }:

# TODO: comment on the nixpkgs issue
# TODO: consider if we can reconfigure the installer to install to a diff place? (maybe its' only usr/etc predefined ones)

# TODO: freebsd patches:
# https://github.com/freebsd/freebsd-ports/blob/6f3fa82c71389a391d0be858721c65084581a1da/x11/nvidia-driver/Makefile#L211-L214
# https://www.google.com/search?q=patch+libegl_nvidia.so+egl_external_platforms.d&client=firefox-b-1-d&ei=UEtDYYylDcbi-gS3tpiYCA&oq=patch+libegl_nvidia.so+egl_external_platforms.d&gs_lcp=Cgdnd3Mtd2l6EAM6BwghEAoQoAE6BQghEKsCOgUIIRCgAUoECEEYAVCpCViWOmCbO2gFcAB4AIABjQGIAY8VkgEEMjkuNJgBAKABAcABAQ&sclient=gws-wiz&ved=0ahUKEwiMjcOf0YPzAhVGsZ4KHTcbBoMQ4dUDCA0&uact=5

# that way the config below would likely just not be necessary
# if we can point it to the /run/opengl-drivers-32(??)/share/egl
# properly...

let
  useNvidiaWayland = false;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
  # this is configuring NVIDIA's EGL loader
  # not sure what happens if this doesn't work or isn't here?
  # wayland worked fine before...
  eglVendorDir = "${nvidiaPackage}/share/glvnd/egl_vendor.d/";
  nvidiaJson = { source = "${eglVendorDir}/10_nvidia.json"; };

  # Interesting...:
  # 1. I can corroborate that the egl-wayland provided libnvidia-egl-wayland
  #    works better than the one provided by nvidia:
  #    -> well, at least Gnome Settings can read the card info, not sure what else
  # 2. VSCodium *requires* the wayland tweaks or else it just shows
  #    a blank/grey/empty/unloaded screen
  # 3. They both purport to be "1.1.7"
  # 4. Do we patch egl-wayland better somehow? weird? TODO
  useEglWaylandSo = false;
  # this is some extra mechanism for NVIDIA to do EGL-y stuff via Wayland? I think? IDK?
  nvidiaExtPlatDir = "${nvidiaPackage}/share/egl/egl_external_platform.d/";
  # this is setup to allow us to quickly switch between egl-wayland impls: (link GH issue)
  nvidiaWaylandJson =
    if !useEglWaylandSo
    then { source = "${nvidiaExtPlatDir}/10_nvidia_wayland.json"; }
    else {
      text = ''
        {
          "file_format_version" : "1.0.0",
          "ICD" : {
            "library_path" : "${pkgs.egl-wayland}/lib/libnvidia-egl-wayland.so.1"
          }
        }
      '';
    };
in
{
  imports = if useNvidiaWayland then [
    ./wayland-tweaks.nix
  ] else [];

  config = {
    environment.etc = {
      # "egl/egl_external_platform.d/10_nvidia_wayland.json" = nvidiaWaylandJson;
      # "glvnd/egl_vendor.d/10_nvidia.json" = nvidiaJson;
    };

    boot.blacklistedKernelModules = [ "nouveau" ];

    boot.initrd.kernelModules = [
      "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"
    ];
    boot.kernelModules = [
      "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"
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
