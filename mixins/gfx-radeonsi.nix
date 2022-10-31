{ pkgs, lib, config, inputs, ... }:

{
  config = {
    hardware.radeon = {
      enable = true;
      utils.enable = true;
    };
  };
}
