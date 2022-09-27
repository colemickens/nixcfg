{ pkgs, lib, inputs, ... }:

let
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
        # gpu-context = "wayland";
      };
    };

    nixpkgs.overlays = [
      (final: prev: (
        {

        }
        // (lib.optionalAttrs patchChromium {
          ungoogled-chromium = (let
            c = prev.ungoogled-chromium;
            in prev.runCommand "wrap-chromium"
              { buildInputs = with pkgs; [ makeWrapper ]; }
              ''
                makeWrapper ${c}/bin/chromium $out/bin/chromium \
                  --add-flags "--enable-features=UseOzonePlatform" \
                  --add-flags "--ozone-platform=wayland"

                ln -sf ${c}/share $out/share
              ''
              );
        })
        // (lib.optionalAttrs patchChromium {
          google-chrome-dev = (let
            c = prev.google-chrome-dev;
            in prev.runCommand "wrap-google-chrome-unstable"
              { buildInputs = with pkgs; [ makeWrapper ]; }
              ''
                makeWrapper ${c}/bin/google-chrome-unstable $out/bin/google-chrome-unstable \
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
