{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nixcfg.desktop.cosmic;
in
{
  imports = [
    ./gui-wayland.nix
  ];

  options = {
    nixcfg.desktop.cosmic = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the Cosmic desktop environment profile.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = (lib.mkIf (inputs ? "cosmic-nightly") [
      inputs.cosmic-nightly.overlays.default
    ]);

    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    environment.sessionVariables = { };

    environment.systemPackages = with pkgs; [
      cosmic-player
      cosmic-reader
      cosmic-wallpapers
      cosmic-ext-ctl
      cosmic-ext-applet-caffeine
      cosmic-ext-applet-external-monitor-brightness
      
      # cosmic-ext-applet-emoji-selector
      # cosmic-ext-applet-minimon
      # cosmic-ext-applet-privacy-indicator
      # cosmic-ext-applet-sysinfo
      # cosmic-ext-applet-weather

      # andromeda # unused
      # chronos # unused
      # examine # unused
      # forecast # unused
      # tasks # unused
      # stellarshot # unused
      # observatory # unused
    ];

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
