{ pkgs, lib, config, inputs, ... }:

{
  config = {
    powerManagement.enable = true;
    services.power-profiles-daemon.enable = true;
  };
}
