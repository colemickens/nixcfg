{ pkgs, ... }:

{
  config = {
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };
    networking.wireless.iwd.enable = true;
    environment.systemPackages = with pkgs; [
      impala
    ];
  };
}
