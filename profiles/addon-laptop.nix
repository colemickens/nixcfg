{ pkgs, lib, config, inputs, ... }:

{
  config = {
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };
  };
}
