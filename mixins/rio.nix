{
  pkgs,
  config,
  inputs,
  ...
}:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  font = prefs.font.monospace.family;
  colors = prefs.themes.alacritty;

  # rioPkg = pkgs.rio;
  rioPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rio;
in
{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.rio = {
          enable = true;
          package = rioPkg;
          settings = {
            fonts = {
              size = 20; # instead of 12 like others?
              regular = {
                family = font;
                style = "Regular";
                weight = 400;
              };
              italic = {
                family = font;
                style = "Italic";
                weight = 400;
              };
            };
            colors = rec {
              background = "${colors.background}";
              foreground = "${colors.foreground}";
              cursor = "${colors.foreground}";

              # black = "${colors.brightBlack}";
              # blue = "${colors.brightBlue}";
              # cyan = "${colors.brightCyan}";
              # green = "${colors.brightGreen}";
              # magenta = "${colors.brightPurple}";
              # red = "${colors.brightRed}";
              # white = "${colors.brightWhite}";
              # yellow = "${colors.brightYellow}";
              black = "${colors.black}";
              blue = "${colors.blue}";
              cyan = "${colors.cyan}";
              green = "${colors.green}";
              magenta = "${colors.purple}";
              red = "${colors.red}";
              white = "${colors.white}";
              yellow = "${colors.yellow}";

              dim-foreground = "${colors.foreground}";
              dim-black = "${colors.black}";
              dim-blue = "${colors.blue}";
              dim-cyan = "${colors.cyan}";
              dim-green = "${colors.green}";
              dim-magenta = "${colors.purple}";
              dim-red = "${colors.red}";
              dim-white = "${colors.white}";
              dim-yellow = "${colors.yellow}";

              light-foreground = "${colors.foreground}";
              light-black = "${colors.brightBlack}";
              light-blue = "${colors.brightBlue}";
              light-cyan = "${colors.brightCyan}";
              light-green = "${colors.brightGreen}";
              light-magenta = "${colors.brightPurple}";
              light-red = "${colors.brightRed}";
              light-white = "${colors.brightWhite}";
              light-yellow = "${colors.brightYellow}";
            };
          };
        };
      };
  };
}
