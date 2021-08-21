{ config, pkgs, lib, ... }:

let 
  useNvidiaWayland = false;
in
{
  config = {
    boot.blacklistedKernelModules = [ "nouveau" ];

    hardware.nvidia.modesetting.enable = true;
    #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
    hardware.nvidia.powerManagement.enable = false;
    
    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = useNvidiaWayland;
      displayManager.gdm.nvidiaWayland = true;
    };
  };
}
