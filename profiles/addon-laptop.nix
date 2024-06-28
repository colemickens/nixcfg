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
    # unused, and not available for aarch64-linux:
    # programs = {
    #   coolercontrol.enable = true;
    # };
    networking.wireless.iwd.enable = true;
  };
}
