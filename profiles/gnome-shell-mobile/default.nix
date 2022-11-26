{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gnomoshell-overlay.nix
  ];

  config = {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    
    environment.systemPackages = with pkgs; [
      bottom
      zellij
    ];

    # unpatched gnome-initial-setup is partially broken in small screens
    services.gnome.gnome-initial-setup.enable = false;

    programs.calls.enable = true;
    hardware.sensor.iio.enable = true; # ?? no idea

    environment.gnome.excludePackages = with pkgs.gnome; [
      # gnome-terminal
    ];

    environment.etc."machine-info".text = lib.mkDefault ''
      CHASSIS="handset"
    '';
  };
}
