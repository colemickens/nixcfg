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
        ### misc
        "google-chrome"
        "google-chrome-dev"
        # "ripcord"

        # trezor-suite... is unfree?
        "trezor-suite"

        ### gaming
        "steam"
        "steam-run"
        "steam-original"
        # "xow_dongle-firmware"
      ];
  };
}
