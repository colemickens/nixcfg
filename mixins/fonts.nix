{ config, pkgs, ... }:
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
      ] ++ [ font.package ];

      fontconfig = {
      #   defaultFonts = {
      #     monospace = [ "Noto Sans Mono" ];
      #     emoji = [ "Noto Color Emoji" ];
      #   };

      #   # NOTE: This was "borrowed".
      #   #  Emojis are still... f'd...

        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <!-- Priority:
                 1. The generic family OR specific family
                 2. The emoji font family (defined in 60-generic.conf)
                 3. All the rest
            -->
            <alias binding="weak">
              <family>monospace</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>
            <alias binding="weak">
              <family>sans-serif</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>

            <alias binding="weak">
              <family>serif</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>

            <selectfont>
              <rejectfont>
                <!-- Reject DejaVu fonts, they interfere with color emoji. -->
                <pattern>
                  <patelt name="family">
                    <string>DejaVu Sans</string>
                  </patelt>
                </pattern>
                <pattern>
                  <patelt name="family">
                    <string>DejaVu Serif</string>
                  </patelt>
                </pattern>
                <pattern>
                  <patelt name="family">
                    <string>DejaVu Sans Mono</string>
                  </patelt>
                </pattern>

                <!-- Also reject EmojiOne Mozilla and Twemoji Mozilla; I want Noto Color Emoji -->
                <pattern>
                  <patelt name="family">
                    <string>EmojiOne Mozilla</string>
                  </patelt>
                </pattern>
                <pattern>
                  <patelt name="family">
                    <string>Twemoji Mozilla</string>
                  </patelt>
                </pattern>
              </rejectfont>
            </selectfont>
          </fontconfig>
        '';
      };
      # home-manager.users.cole = { pkgs, ... }: {
      #   fonts.fontconfig.enable = true;
      # };
    };
  };
}

