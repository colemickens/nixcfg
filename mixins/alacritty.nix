{ pkgs, config, inputs, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs inputs; };
  font = prefs.font;
  colors = prefs.themes.alacritty;

  # alacrittyPkg = pkgs.alacritty;
  alacrittyPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.alacritty;
in
{
  config = {
    # nixpkgs.overlays = [
    #   (prev: final: {
    #     alacritty = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.alacritty;
    #   })
    # ];
    home-manager.users.cole = { pkgs, ... }: {
      programs.alacritty = {
        enable = true;
        package = alacrittyPkg;
        settings = {
          env = {
            TERM = "xterm-256color";
          };
          shell = prefs.default_shell;
          font = {
            normal.family = "${font.monospace.family}";
            # normal.family = "IntelOne Mono";
            # normal.family = "Comic Mono";
            size = font.size;
          };
          #cursor.style = {
          #  shape = "Block";
          #  blinking = "Always";
          #};
          #cursor.blink_interval = 250;
          window = {
            opacity = 1.0;
            padding = { x = 5; y = 5; };
          };
          colors = rec {
            draw_bold_text_with_bright_colors = colors.bold_as_bright;
            primary.foreground = colors.foreground;
            primary.background = colors.background;

            normal = {
              black = colors.black;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.cyan;
              white = colors.white;
            };
            bright = {
              black = colors.brightBlack;
              red = colors.brightRed;
              green = colors.brightGreen;
              yellow = colors.brightYellow;
              blue = colors.brightBlue;
              magenta = colors.brightPurple;
              cyan = colors.brightCyan;
              white = colors.brightWhite;
            };
          };
        };
      };
    };
  };
}
