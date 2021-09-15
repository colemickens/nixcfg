{ config, pkgs, lib, ... }:

let 
  useNvidiaWayland = false;
in
{
  config = {
    boot.blacklistedKernelModules = [ "nouveau" ];

    boot.initrd.kernelModules = [
      "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"
    ];
    boot.kernelModules = [
      "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"
    ];

    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    hardware.nvidia.powerManagement.enable = false;
    
    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = useNvidiaWayland;
      displayManager.gdm.nvidiaWayland = useNvidiaWayland;
    };
  };
}
