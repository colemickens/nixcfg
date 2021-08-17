{ config, pkgs, lib, ... }:

{
  config = {
    boot.blacklistedKernelModules = [ "nouveau" ];

    hardware.nvidia.modesetting.enable = true;
    #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
    hardware.nvidia.powerManagement.enable = false;
    
    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.nvidiaWayland = true;
    };
  };
}
