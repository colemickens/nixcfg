{ pkgs, inputs, ... }:

{
  config = {
    # setup package overrides for:
    # - vscodium
    # - discord

    # setup env vars for:
    # - firefox env vars
    nixpkgs.overlays = [
      (final: prev: {
        vscodium = (prev.runCommandNoCC "codium"
          { buildInputs = with pkgs; [ makeWrapper ]; }
          ''
            makeWrapper ${prev.vscodium}/bin/codium $out/bin/codium \
              --add-flags "--enable-features=UseOzonePlatform" \
              --add-flags "--ozone-platform=wayland"

            ln -sf ${prev.vscodium}/share $out/share
          ''
          );

        element-desktop = (prev.runCommandNoCC "element"
            { buildInputs = with prev; [ makeWrapper ]; }
            ''
              makeWrapper ${prev.element-desktop}/bin/element-desktop $out/bin/element-desktop \
                --add-flags "--enable-features=UseOzonePlatform" \
                --add-flags "--ozone-platform=wayland"

              ln -sf ${prev.element-desktop}/share $out/share
            ''
          );

        ungoogled-chromium = (let
          c = inputs.nixos-unstable.legacyPackages.${prev.system}.ungoogled-chromium;
          #c = prev.ungoogled-chromium;
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
    ];
  };
}
