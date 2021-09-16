{ config, pkgs, lib, ... }:

let 
  useNvidiaWayland = false;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
  eglVendorDir = "${nvidiaPackage}/share/glvnd/egl_vendor.d/";
in
{
  config = {
    environment.etc = {
      "egl/egl_external_platform.d/nvidia_wayland.json".source 
        = "${eglVendorDir}/nvidia_wayland.json";
      "egl/egl_external_platform.d/nvidia.json".source 
        = "${eglVendorDir}/nvidia.json";

      # libglvnd needs it too?
      # glvnd/egl_vendor.d/10_nvidia.json ?
      # "egl/egl_external_platform.d/nvidia_wayland.json".source 
      #   = "${eglVendorDir}/nvidia_wayland.json";
      # "egl/egl_external_platform.d/nvidia.json".source 
      #   = "${eglVendorDir}/nvidia.json";
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
