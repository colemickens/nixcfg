{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      ### misc
      # "nvidia-x11" # TODO: move this since we don't get generations in the installer grub anyway
      
      ### misc
      "google-chrome"
      "google-chrome-dev"

      "google-chrome-120.0.6099.216" # uh, why is it suddenly making me include version?
    ];
  };
}
