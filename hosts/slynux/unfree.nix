{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "cudatoolkit"
      
      # profiles/gui
      "ripcord"
      "google-chrome-dev"
    ];
  };
}
