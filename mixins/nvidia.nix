{ config, pkgs, lib, ... }:
{
  config = {
    hardware.nvidia.modesetting.enable = true;
      # hardware.nvidia.powerManagement.enable = true; # TODO: test
      services.xserver = {
        enable = true;
        videoDriver = "nvidia";
        # autoSuspend = false; # nvidia doesn't wake up, others seem to notice this too?
        displayManager.gdm.nvidiaWayland =
          (config.services.xserver.displayManager.gdm.enable == true);
      };
  };
}
