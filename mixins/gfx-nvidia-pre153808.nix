{ config, pkgs, lib, ... }:

let
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;
  nvLatest =
    if (lib.versionOlder nvBeta.version nvStable.version)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;
  # nvEffective = nvLatest;
  nvidiaPkg = nvLatest;

  extraEnv = {
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    EGL_PLATFORM = "wayland";
  };
  # https://github.com/elFarto/nvidia-vaapi-driver
in {
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      wayland.windowManager.sway = {
        extraOptions = [ "--unsupported-gpu" ];
      };
    };
    environment.variables = extraEnv;
    environment.sessionVariables = extraEnv;

    environment.systemPackages = with pkgs; [
      gwe
    ];

    hardware = {
      opengl = {
        extraPackages = []
        ++ lib.optionals (pkgs.system=="x86_64-linux") (with pkgs; [
          pkgs.nvidia-vaapi-driver
        ]);
      };
    };
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidiaPkg;
    hardware.nvidia.powerManagement.enable = false;

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = true;
    };
  };
}
