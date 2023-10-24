{ config, pkgs, lib, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      libva-utils
      glxinfo
      vulkan-tools
      glmark2
      mesa-demos
    ];
  };
}
