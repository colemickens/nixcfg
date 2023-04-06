{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      # "amdgpu-pro" # TODO: not sure we're keeping this anyway
      "ripcord"
      "google-chrome-dev"
      "steam" "steam-run" "steam-original"
      "xow_dongle-firmware"

      # nvtop
      "cudatoolkit"
    ];
  };
}
