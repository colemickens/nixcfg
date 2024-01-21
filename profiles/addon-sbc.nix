{ pkgs, lib, config, inputs, ... }:

{
  config = {
    networking.wireless.iwd.enable = true;
  };
}
