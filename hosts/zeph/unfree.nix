{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      ### misc
      "google-chrome"
      "google-chrome-dev"
      # "ripcord"

      ### gaming
      "steam"
      "steam-run"
      "steam-original"
      # "xow_dongle-firmware"
    ];
  };
}
