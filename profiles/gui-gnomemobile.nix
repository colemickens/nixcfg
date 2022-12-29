{ pkgs, lib, config, inputs, ... }:

{
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

    nixpkgs.overlays = [
      (final: prev: {
        gnome = prev.gnome // rec {
          mutter = prev.gnome.mutter.overrideAttrs (super: rec {
            # https://gitlab.gnome.org/verdre/mutter/-/tree/mobile-shell-devel
            # nov 26 2022:
            version = "b77f0a30604cf6383ebf52ffcd7d865983938393"; # mobile-shell
            src = prev.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "verdre";
              repo = "mutter";
              rev = version;
              sha256 = "sha256-PC39VPrEk6w7+YOgBUT7DoUUYOaagaTOUWVKf1DEId8=";
            };
            patches = [
              # (prev.fetchpatch {
              #   url = "https://gitlab.gnome.org/GNOME/mutter/-/commit/285a5a4d54ca83b136b787ce5ebf1d774f9499d5.patch";
              #   sha256 = "/npUE3idMSTVlFptsDpZmGWjZ/d2gqruVlJKq4eF4xU=";
              # })
            ];
          });
          gnome-shell = (prev.gnome.gnome-shell.override { inherit mutter; }).overrideAttrs (super: rec {
            # https://gitlab.gnome.org/verdre/gnome-shell/-/tree/mobile-shell-devel
            version = "d2dc9c265c3a7485eba6b56ab6bee3be3f37da27"; # mobile-shell
            src = prev.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "verdre";
              repo = "gnome-shell";
              rev = version;
              fetchSubmodules = true;
              sha256 = "sha256-cJWdNEHlRTyXGux+wl5kUXvUlY+gEXbwiEmyHtc8nLM=";
            };
            postPatch = ''
              patchShebangs src/data-to-c.pl
            '';
          });
        };
      })
    ];
  };
}
