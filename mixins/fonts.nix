{ config, pkgs, lib, ... }:
let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;
in
{
  config = {
    fonts = {
      fonts = with pkgs; [
        corefonts ttf_bitstream_vera
        noto-fonts noto-fonts-cjk noto-fonts-emoji
        iosevka # first place
        jetbrains-mono # second place
        monoid # untested
        fira-code fira-code-symbols # its okay, but wide
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

