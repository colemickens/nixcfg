{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  config = {
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };
    programs = {
      coolercontrol.enable = true;
    };
    networking.wireless.iwd.enable = true;
  };
}
