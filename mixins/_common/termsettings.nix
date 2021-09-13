{ pkgs, ...}: 

{
  fonts = rec {
    # TODO: nothing ensures the font is available in
    # HM modules that don't use `fonts.default.package`
    
    default = iosevka;
    
    scp = {
      name = "Source Code Pro";
      size = 11;

      package = pkgs.source-code-pro;
    };

    iosevka = {
      name = "Iosevka";
      size = 13;
      package = pkgs.iosevka;
    };
  };
  colors = rec {
    default = tango;

    campbell = {
      cursorColor = "#FFFFFF";
      #selectionBackground = "#FFFFFF"; # ms-terminal-only

      foreground = "#CCCCCC";
      foregroundBold = "#FFFFFF"; # termite-only
      background = "#0C0C0C";

      bold_as_bright = true;

      black = "#0C0C0C";
      blue = "#0037DA";
      cyan = "#3A96DD";
      green = "#13A10E";
      purple = "#881798";
      red = "#C50F1F";
      white = "#CCCCCC";
      yellow = "#C19C00";
      brightBlack = "#767676";
      brightBlue = "#3B78FF";
      brightCyan = "#61D6D6";
      brightGreen = "#16C60C";
      brightPurple = "#B4009E";
      brightRed = "#E74856";
      brightWhite = "#F2F2F2";
      brightYellow = "#F9F1A5";
    };

    onehalfdark = {
      cursorColor = "#FFFFFF";

      foreground = "#DCDFE4";
      foregroundBold = "#FFFFFF"; # termite-onnly
      background = "#282C34";

      bold_as_bright = true;
      
      black = "#282C34";
      red = "#E06C75";
      green = "#98C379";
      yellow = "#E5C07B";
      blue = "#61AFEF";
      purple = "#C678DD";
      cyan = "#56B6C2";
      white = "#DCDFE4";
      brightBlack = "#5A6374";
      brightRed = "#E06C75";
      brightGreen = "#98C379";
      brightYellow = "#E5C07B";
      brightBlue = "#61AFEF";
      brightPurple = "#C678DD";
      brightCyan = "#56B6C2";
      brightWhite = "#DCDFE4";
    };

    tango = {
        cursorColor = "#FFFFFF";

        foreground = "#cccccc";
        foregroundBold = "#FFFFFF"; # termite only
        background = "#0C0C0C";

        bold_as_bright = true;

        black = "#000000";
        red = "#CC0000";
        green = "#4E9A06";
        yellow = "#C4A000";
        blue = "#3465A4";
        purple = "#75507B";
        cyan = "#06989A";
        white = "#D3D7CF";
        brightBlack = "#555753";
        brightRed = "#EF2929";
        brightGreen = "#8AE234";
        brightYellow = "#FCE94F";
        brightBlue = "#729FCF";
        brightPurple = "#AD7FA8";
        brightCyan = "#34E2E2";
        brightWhite = "#EEEEEC";
    };
  };
}
