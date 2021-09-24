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
        corefonts
        cascadia-code
        fira-code fira-code-symbols
        jetbrains-mono
        gelasio
        iosevka
        noto-fonts noto-fonts-cjk noto-fonts-emoji
        source-code-pro
        ttf_bitstream_vera
        font-awesome
        plex-mono
        roboto-mono
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

