{ config, pkgs, lib, ... }:

let
  nverStable = config.boot.kernelPackages.nvidiaPackages.stable.version;
  nverBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;
  nvidiaPackage =
    if (lib.versionOlder nverBeta nverStable)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;

  extraEnv = { WLR_NO_HARDWARE_CURSORS = "1"; };
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      wayland.windowManager.sway = {
        extraOptions = [ "--unsupported-gpu" ];
      };
    };
    environment.variables = extraEnv;
    environment.sessionVariables = extraEnv;

    environment.systemPackages = with pkgs; [
      glxinfo
      vulkan-tools
      glmark2
    ];

    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidiaPackage;
    hardware.nvidia.powerManagement.enable = false;

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = true;
    };
  };
}
