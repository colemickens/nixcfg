{ pkgs, ... }: {
  fonts = {
    fontconfig = {
      defaultFonts = {
        monospace = [ "Noto Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
      localConf = ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
        <fontconfig>
          <match>
            <test qual="any" name="family">
                <string>serif</string>
            </test>
            <edit name="family" mode="prepend_first">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <match target="font">
            <test name="family" compare="eq">
                <string>Roboto</string>
            </test>
            <edit name="family" mode="append_last">
              <string>sans-serif</string>
            </edit>
          </match>

          <match target="pattern">
            <test qual="any" name="family">
                <string>sans-serif</string>
            </test>
            <edit name="family" mode="prepend_first">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <match target="pattern">
            <test qual="any" name="family">
                <string>monospace</string>
            </test>
            <edit name="family" mode="prepend_first">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <alias binding="strong">
            <family>emoji</family>
            <default><family>Noto Color Emoji</family></default>
          </alias>

          <alias binding="strong">
            <family>Apple Color Emoji</family>
            <prefer><family>Noto Color Emoji</family></prefer>
            <default><family>sans-serif</family></default>
          </alias>
          <alias binding="strong">
            <family>Segoe UI Emoji</family>
            <prefer><family>Noto Color Emoji</family></prefer>
            <default><family>sans-serif</family></default>
          </alias>
          <alias binding="strong">
            <family>Twitter Color Emoji</family>
            <prefer><family>Noto Color Emoji</family></prefer>
            <default><family>sans-serif</family></default>
          </alias>
        </fontconfig>
      '';
    };
    fonts = with pkgs; [
      corefonts
      inconsolata
      overpass
      font-awesome nerdfonts powerline-fonts
      noto-fonts noto-fonts-cjk noto-fonts-emoji
    ];
  };
}

