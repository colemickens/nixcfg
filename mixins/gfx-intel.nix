{ pkgs, lib, config, inputs, ... }:

{
  config = {
    hardware.intelgpu = {
      enable = true;
      utils.enable = true;
    };
  };
}
