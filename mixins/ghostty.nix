{ inputs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs = {
          ghostty = {
            enable = true;
            package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
            themes = {
              cosmic-dark = {
                palette = [
                  "0=#1B1B1B"
                  "1=#F16161"
                  "2=#7CB987"
                  "3=#DDC74C"
                  "4=#6296BE"
                  "5=#BE6DEE"
                  "6=#49BAC8"
                  "7=#BEBEBE"
                  "8=#808080"
                  "9=#FF8985"
                  "10=97D5A0"
                  "11=FAE365"
                  "12=7DB1DA"
                  "13=D68EFF"
                  "14=49BAC8"
                  "15=C4C4C4"
                ];
                background = "1A153D";
                foreground = "C4C4C4";
                cursor-color = "C4C4C4";
                selection-background = "8E8E8E";
                selection-foreground = "C4C4C4";
              };
              cosmic-light = {
                palette = [
                  "0=#292929"
                  "1=#8C151F"
                  "2=#145129"
                  "3=#624000"
                  "4=#003F5F"
                  "5=#6D169C"
                  "6=#004F57"
                  "7=#8a8a8a" # ??
                  "8=#808080"
                  "9=#9D2329"
                  "10=235D34"
                  "11=714B00"
                  "12=054B6F"
                  "13=7A28A9"
                  "14=005C5D"
                  "15=D7D7D7"
                ];
                background = "B2A5CE";
                foreground = "292929";
                cursor-color = "292929";
                selection-background = "181818";
                selection-foreground = "808080";
              };
            };
            settings = {
              font-family = "Iosevka Term";
              font-style = "Medium";
              font-size = 11;
              adjust-cell-width = "-5%";
              background-opacity = "0.85";
              term = "xterm-256color";
              window-decoration = false;

              # theme = "light:ayu_light,dark:ayu";

              # cosmic
              theme = "light:cosmic-light,dark:cosmic-dark";
              # background-opacity = "0.85";
              # misc:
              # theme = "light:Adwaita,dark:Adwaita Dark";
              # theme = "light:Builtin Tango Light,dark:Builtin Tango Dark";
            };
          };
        };
      };
  };
}
