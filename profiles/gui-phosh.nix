{ pkgs, lib, config, inputs, ... }:

let
in
{
  imports = [
    # ../gui.nix

    # ../../mixins/gtk.nix

    # ../../mixins/mako.nix
    # ../../mixins/sirula.nix
    # ../../mixins/sway.nix # contains swayidle/swaylock config
    # ../../mixins/waybar.nix

    # inputs.hyprland.nixosModules.default
  ];
  config = {
    powerManagement.enable = true;
    hardware.opengl.enable = true;

    services.xserver.desktopManager.gnome.enable = true;

    # unpatched gnome-initial-setup is partially broken in small screens
    services.gnome.gnome-initial-setup.enable = false;

    # programs.phosh.enable = true;
    services.xserver.desktopManager.phosh = {
      enable = true;
      group = "users";
      user = "cole";
    };
    programs.calls.enable = true;
    hardware.sensor.iio.enable = true; # ?? no idea

    services.gnome.gnome-online-accounts.enable = lib.mkForce false;
    environment.gnome.excludePackages = with pkgs.gnome; [
      # gnome-terminal
      evolution-data-server
      # gnome-online-accounts
      yelp
      geary
      epiphany
      sushi
    ];

    environment.etc."machine-info".text = lib.mkDefault ''
      CHASSIS="handset"
    '';
  };
}
