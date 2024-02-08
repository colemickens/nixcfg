{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  config = {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
        "cudatoolkit"

        # profiles/gui
        "ripcord"
        "steam"
        "steam-original"
        "steam-run"
        "google-chrome-dev"

        "xow_dongle-firmware"
      ];
  };
}
