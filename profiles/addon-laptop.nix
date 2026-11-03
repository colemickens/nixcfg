{ pkgs, ... }:

{
  config = {
    nixcfg.common.defaultNetworking = false;

    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };

    networking.networkmanager.enable = true;
    networking.useDHCP = false;
    networking.dhcpcd.enable = false;

    environment.systemPackages = with pkgs; [
      impala
    ];
  };
}
