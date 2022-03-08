{ pkgs, inputs, ...}:

# TODO: switch to nix-rice?
let
  termlib = import ./termlib.nix { inherit pkgs; };
  iterm_cs = "purplepeter";
  #iterm_cs = "Builtin Tango Dark";
  #iterm_cs = "Builtin Solarized Dark";
in {
  termlib = termlib;
  #default_term = "wezterm";
  default_term = "alacritty";
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
  colors.default = {
    bold_as_bright = true;
  } // inputs.nix-rice.colorschemes.${iterm_cs};
}
