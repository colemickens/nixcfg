{ pkgs, lib, config, inputs, ... }:

{
  imports = [
  ];
  config = {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    nixpkgs.overlays = [
      (final: prev: {
        gnome = prev.gnome // rec {
          mutter = prev.gnome.mutter.overrideAttrs (super: rec {
            version = "9bd6ecb44f7bf6f667fe734fec2754b0eb54c60d"; # mobile-shell
            src = prev.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "verdre";
              repo = "mutter";
              rev = version;
              sha256 = "sha256-nz5PYbH0MEAKkqYzFSsSmX+WmYXNwUQuaCsPj/2/mDM=";
            };
            patches = [
              (prev.fetchpatch {
                url = "https://gitlab.gnome.org/GNOME/mutter/-/commit/285a5a4d54ca83b136b787ce5ebf1d774f9499d5.patch";
                sha256 = "/npUE3idMSTVlFptsDpZmGWjZ/d2gqruVlJKq4eF4xU=";
              })
            ];
          });
          gnome-shell = (prev.gnome.gnome-shell.override { inherit mutter; }).overrideAttrs (super: rec {
            version = "82d68488ce05e51f220f361fdbf2a888e51fc12b";
            src = prev.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "verdre";
              repo = "gnome-shell";
              rev = version;
              fetchSubmodules = true;
              sha256 = "sha256-AYtA3zrrGz8hwkDW8AyZU/zUs4Oz46J8MiyGz/aHZUE=";
            };
            postPatch = ''
              patchShebangs src/data-to-c.pl
            '';
          });
        };
      })
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
