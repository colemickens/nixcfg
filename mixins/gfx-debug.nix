{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    environment.systemPackages = with pkgs; [
      libva-utils
      mesa-demos
      vulkan-tools
      glmark2
      mesa-demos
    ];
  };
}
