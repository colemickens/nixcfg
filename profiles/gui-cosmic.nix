{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    ./gui-wayland.nix
  ];

  config =
    let
      tty = "tty${toString config.systemd.services.greetd.vt}";
    in
    {
      nixpkgs.overlays = [(final: prev: {
        cosmic-player = prev.cosmic-player.overrideAttrs(old: {
          buildInputs = old.buildInputs ++ [ prev.gst_all_1.gst-plugins-ugly ];
        });
      })];
      services.desktopManager.cosmic = {
        enable = true;
      };

      services.displayManager.cosmic-greeter = {
        enable = true;
      };

      services.supergfxd.enable = false;

      environment.sessionVariables = {
        # COSMIC_DATA_CONTROL_ENABLED = "1";
      };
      environment.systemPackages = with pkgs; [
        cosmic-player
        # cosmic-reader
        cosmic-ext-ctl
        # cosmic-ext-applet-clipboard-manager
        # cosmic-ext-applet-emoji-selector
        # cosmic-ext-applet-external-monitor-brightness
        # cosmic-ext-applet-caffeine
        # cosmic-ext-tweaks

        # andromeda
        # chronos
        # examine
        # forecast
        # tasks
        # stellarshot
        # observatory
      ];

      networking.networkmanager.enable = false;

      home-manager.users.cole =
        { pkgs, config, ... }@hm:
        {
          home.packages = with pkgs; [
            adw-gtk3
          ];

          # WIP: trying to get cosmic to style gtk3 apps
          xdg.configFile."gtk-3.0/settings.ini".text = ''
            [Settings]
            gtk-theme-name=adw-gtk3
          '';
        };
    };
}
