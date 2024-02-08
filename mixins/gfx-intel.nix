{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  config = {
    hardware.opengl.enable = true;

    # hardware.intelgpu = {
    #   enable = true;
    #   utils.enable = true;
    # };
  };
}
