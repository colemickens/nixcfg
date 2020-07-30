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

      # fontconfig = {
      #   defaultFonts = {
      #     monospace = [ "Noto Sans Mono" ];
      #     emoji = [ "Noto Color Emoji" ];
      #   };

      #   # NOTE: This was "borrowed".
      #   #  Emojis are still... f'd... 

      #   localConf = ''
      #     <?xml version='1.0'?>
      #     <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
      #     <fontconfig>
      #       <match>
      #         <test qual="any" name="family">
      #             <string>serif</string>
      #         </test>
      #         <edit name="family" mode="prepend_first">
      #           <string>Noto Color Emoji</string>
      #         </edit>
      #       </match>

      #       <match target="font">
      #         <test name="family" compare="eq">
      #             <string>Roboto</string>
      #         </test>
      #         <edit name="family" mode="append_last">
      #           <string>sans-serif</string>
      #         </edit>
      #       </match>

      #       <match target="pattern">
      #         <test qual="any" name="family">
      #             <string>sans-serif</string>
      #         </test>
      #         <edit name="family" mode="prepend_first">
      #           <string>Noto Color Emoji</string>
      #         </edit>
      #       </match>

      #       <match target="pattern">
      #         <test qual="any" name="family">
      #             <string>monospace</string>
      #         </test>
      #         <edit name="family" mode="prepend_first">
      #           <string>Noto Color Emoji</string>
      #         </edit>
      #       </match>

      #       <alias binding="strong">
      #         <family>emoji</family>
      #         <default><family>Noto Color Emoji</family></default>
      #       </alias>

      #       <alias binding="strong">
      #         <family>Apple Color Emoji</family>
      #         <prefer><family>Noto Color Emoji</family></prefer>
      #         <default><family>sans-serif</family></default>
      #       </alias>
      #       <alias binding="strong">
      #         <family>Segoe UI Emoji</family>
      #         <prefer><family>Noto Color Emoji</family></prefer>
      #         <default><family>sans-serif</family></default>
      #       </alias>
      #       <alias binding="strong">
      #         <family>Twitter Color Emoji</family>
      #         <prefer><family>Noto Color Emoji</family></prefer>
      #         <default><family>sans-serif</family></default>
      #       </alias>
      #     </fontconfig>
      #   '';
      # };
      
      # home-manager.users.cole = { pkgs, ... }: {
      #   fonts.fontconfig.enable = true;
      # };
    };
  };
}

