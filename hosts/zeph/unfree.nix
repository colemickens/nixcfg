{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      ### misc
      "google-chrome"
      "google-chrome-dev"
      # "ripcord"

      # trezor-suite... is unfree?
      "trezor-suite-23.12.3" # why's the version inside?
      "trezor-suite-24.1.2" # why's the version inside?

      "ngrok" # ugh, dev for work

      ### gaming
      "steam"
      "steam-run"
      "steam-original"
      # "xow_dongle-firmware"
    ];
  };
}
