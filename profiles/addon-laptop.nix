{ pkgs, ... }:

{
  config = {
    nixcfg.common.defaultNetworking = false;

    services = {
      asusd.enable = false;
      power-profiles-daemon.enable = true;
      supergfxd.enable = false;
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
