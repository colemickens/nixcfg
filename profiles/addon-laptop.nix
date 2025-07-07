{ pkgs, ... }:

{
  config = {
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
