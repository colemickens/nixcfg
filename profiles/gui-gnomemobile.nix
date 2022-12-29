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
            # https://gitlab.gnome.org/verdre/mutter/-/tree/${branch}
            # 2022/12/14: (mobile-shell branch)
            version = "4e6674075cfd7e644da14837a661ed3a1fb0395b"; # mobile-shell
            src = prev.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "verdre";
              repo = "mutter";
              rev = version;
              sha256 = "sha256-AgisT14I22q8VEkc7IionZmZi89KMEHBVwQLVdL22Ck=";
            };
            patches = [
              # (prev.fetchpatch {
              #   url = "https://gitlab.gnome.org/GNOME/mutter/-/commit/285a5a4d54ca83b136b787ce5ebf1d774f9499d5.patch";
              #   sha256 = "/npUE3idMSTVlFptsDpZmGWjZ/d2gqruVlJKq4eF4xU=";
              # })
            ];
          });
          gnome-shell = (prev.gnome.gnome-shell.override { inherit mutter; }).overrideAttrs (super: rec {
            # https://gitlab.gnome.org/verdre/gnome-shell/-/tree/${branch}
            # 2022/11/22: (branch: mobile-shell)
            version = "4ef0db259a1815d00656c3adab89df14f272067e"; # mobile-shell
            src = prev.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "verdre";
              repo = "gnome-shell";
              rev = version;
              fetchSubmodules = true;
              sha256 = "sha256-pIBJFyg1XDVrZdPhbDYdSGrDEwa1xTT4gSnF7z7tLpw=";
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
