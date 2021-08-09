{ config, pkgs, lib, ... }:

{
  config = {
    boot.blacklistedKernelModules = [ "nouveau" ];

    hardware.nvidia.modesetting.enable = true;
    #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    #hardware.nvidia.powerManagement.enable = true; # TODO: test

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.nvidiaWayland = true;
    };
  };
}
