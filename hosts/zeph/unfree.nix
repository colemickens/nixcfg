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
        "apple_cursor"
        "google-chrome"
        "google-chrome-dev"

        "firefox-bin"
        "firefox-bin-unwrapped"

        # trezor-suite... is unfree?
        "trezor-suite"

        ### gaming
        "steam"
        "steam-run"
        "steam-original"
        "steam-unwrapped"
        # "xow_dongle-firmware"
      ];
  };
}
