{ config, pkgs, lib, ... }:

let
  nverStable = config.boot.kernelPackages.nvidiaPackages.stable.version;
  nverBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;
  nvidiaPackage =
    if (lib.versionOlder nverBeta nverStable)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;

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
      libva-utils
      glxinfo
      vulkan-tools
      glmark2
    ];

    hardware = {
      opengl = {
        extraPackages = []
        ++ lib.optionals (pkgs.system=="x86_64-linux") (with pkgs; [
          pkgs.mesa.drivers
        ]);
      };
    };
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidiaPackage;
    hardware.nvidia.powerManagement.enable = false;

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = true;
    };
  };
}
