{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  config = {
    hardware.graphics.enable = true;

    # hardware.intelgpu = {
    #   enable = true;
    #   utils.enable = true;
    # };
  };
}
