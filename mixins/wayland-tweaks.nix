{ pkgs, lib, inputs, ... }:

let
  patchVscodium = true;
  patchChromium = true;
in {
  config = {
    # setup package overrides for:
    # - vscodium
    # - discord

    # setup env vars for:
    # - firefox env vars
    home-manager.users.cole = { pkgs, ... }: {
      programs.mpv.config = {
        gpu-context = "wayland";
      };
    };

    nixpkgs.overlays = [
      (final: prev: (
        {
          # idk? just doesn't work?
          # wlroots = prev.wlroots.overrideAttrs (old: rec {
          #   patches = ((old.patches or []) ++ [
          #     ../misc/wlroots-chro1me.patch
          #   ]);
          # });
          xwayland = prev.xwayland.overrideAttrs (old: rec {
            version = "21.1.3";
            src = prev.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "xorg";
              repo = "xserver";
              rev = "21e3dc3b5a576d38b549716bda0a6b34612e1f1f";
              sha256 = "sha256-i2jQY1I9JupbzqSn1VA5JDPi01nVA6m8FwVQ3ezIbnQ=";
            };
          });
        } //

        (lib.optionalAttrs patchVscodium {
          vscodium = (prev.runCommandNoCC "codium"
            { buildInputs = with pkgs; [ makeWrapper ]; }
            ''
              makeWrapper ${prev.vscodium}/bin/codium $out/bin/codium \
                --add-flags "--enable-features=UseOzonePlatform" \
                --add-flags "--ozone-platform=wayland"

              ln -sf ${prev.vscodium}/share $out/share
            ''
            );
        }) //
        (lib.optionalAttrs patchChromium {
          ungoogled-chromium = (let
            #c = inputs.nixos-unstable.legacyPackages.${prev.system}.ungoogled-chromium;
            c = prev.ungoogled-chromium;
            in prev.runCommandNoCC "wrap-chromium"
              { buildInputs = with pkgs; [ makeWrapper ]; }
              ''
                makeWrapper ${c}/bin/chromium $out/bin/chromium \
                  --add-flags "--enable-features=UseOzonePlatform" \
                  --add-flags "--ozone-platform=wayland"

                ln -sf ${c}/share $out/share
              ''
              );
        })
      ))
    ];
  };
}
