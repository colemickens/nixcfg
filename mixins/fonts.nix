{ config, pkgs, lib, ... }:
let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;

  customIosevkaTerm = (pkgs.iosevka.override {
    set = "term";
    # https://github.com/be5invis/Iosevka/blob/6b2b8b7e643a13e1cf56787aed4fd269dd3e044b/build-plans.toml#L186
    privateBuildPlan = {
      family = "Iosevka Term";
      spacing = "term";
      snapshotFamily = "iosevka";
      snapshotFeature = "\"NWID\" on, \"ss03\" on";
      export-glyph-names = true;
      no-cv-ss = true;
    };
  });

  _iosevka = pkgs.iosevka;
  #_iosevka = customIosevkaTerm;
in
{
  config = {
    fonts = {
      fonts = with pkgs; [
        corefonts ttf_bitstream_vera
        noto-fonts noto-fonts-cjk noto-fonts-emoji
        _iosevka # first place
        jetbrains-mono # second place
        font-awesome
        gelasio # ???
      ] ++ [ font.package ];

      fontconfig = {
        defaultFonts = {
          monospace = [ "Noto Sans Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
