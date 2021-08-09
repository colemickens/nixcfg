{ config, pkgs, lib, ... }:

{
  config = {
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  
    # hardware.nvidia.powerManagement.enable = true; # TODO: test

    services.xserver = {
      enable = (config.services.xserver.displayManager.gdm.enable == true);
      # autoSuspend = false; # nvidia doesn't wake up, others seem to notice this too?
      displayManager.gdm.nvidiaWayland =
        (config.services.xserver.displayManager.gdm.enable == true);
    };
  };
}
