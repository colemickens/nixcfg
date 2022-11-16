{ pkgs, lib, config, inputs, ... }:

{
  config = {
    hardware.gpu.radeon = {
      enable = true;
      utils.enable = true;
    };
  };
}
