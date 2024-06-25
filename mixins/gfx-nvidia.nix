{
  config,
  pkgs,
  lib,
  ...
}:

let
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;
  nvidiaPkg =
    if (lib.versionOlder nvBeta.version nvStable.version) then
      config.boot.kernelPackages.nvidiaPackages.stable
    else
      config.boot.kernelPackages.nvidiaPackages.beta;
in
{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        wayland.windowManager.sway.extraOptions = [ "--unsupported-gpu" ];
        home.sessionVariables.WLR_RENDERER = lib.mkForce "gles2";
      };

    environment.sessionVariables = {
      WLR_DRM_NO_ATOMIC = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      EGL_PLATFORM = "wayland";
    };

    # this requires "cmpkgs-opengl" which ... you know...
    # hardware.gpu.nvidia = {
    #   enable = true;
    #   package = nvidiaPkg;
    #   open = true;
    #   modesetting.enable = true;
    #   nvidiaSettings = false;
    #   powerManagement.enable = true;
    # };

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      package = nvidiaPkg;
      open = true;
      modesetting.enable = true;
      nvidiaSettings = false;
      powerManagement.enable = false;
    };
  };
}
