{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix
  ];
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.greeters.pantheon.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.pantheon.enable = true;

    services.pantheon.apps.enable = true;
    services.pantheon.contractor.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {

      };
      home.packages = with pkgs; [
        # sway-related
        gnome3.gnome-tweaks
      ];
    };
  };
}
