{ pkgs, inputs, ... }:

let
  colorscheme = inputs.nix-rice.colorschemes."purplepeter";

  bg_gruvbox_rainbow = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/master/png/gruvbox-dark-rainbow.png";
    sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
  };
  colordefs = {
    bold_as_bright = true;
  };
  customIosevkaTerm = (pkgs.iosevka.override {
    set = "term";
    # https://github.com/be5invis/Iosevka/blob/6b2b8b7e643a13e1cf56787aed4fd269dd3e044b/build-plans.toml#L186
    privateBuildPlan = {
      family = "Iosevka Term";
      spacing = "term";
      snapshotFamily = "iosevka";
      snapshotFeature = "\"NWID\" on, \"ss03\" on";
      export-glyph-names = true;
      no-cv-ss = true;
    };
  });
  _iosevka = pkgs.iosevka;
  #_iosevka = customIosevkaTerm;
in
rec {
  # all configured with HM, so just use binary name
  editor = "hx";
  shell = { program = "zsh"; args = [ ]; };
  default_term = "alacritty";
  default_launcher = "sirula";

  gtk = {
    font = { name = "${font.default.family} 11"; package = font.default.package; };
    preferDark = true;
    iconTheme = { name = "Numix Circle"; package = pkgs.numix-icon-theme; };
    theme = { name = "Arc-Dark"; package = pkgs.arc-theme; };
  };
  cursor = { name = "capitaine-cursors-white"; package = pkgs.capitaine-cursors; };
  themes = {
    alacritty = colorscheme // colordefs;
    sway = colorscheme // colordefs;
    wezterm = colorscheme // colordefs;
    zellij = colorscheme // colordefs;
  };
  inherit colorscheme;

  bgcolor = "#000000";
  background = "${bgcolor} solid_color";
  # background = "${bg_gruvbox_rainbow} center #333333";
  wallpaper = bg_gruvbox_rainbow;

  swayfonts = {
    names = [ font.default.family font.fallback.family ];
    style = "Heavy";
    size = 10.0;
  };

  font = rec {
    size = 13;
    default = sans;

    sans = { family = "Noto Sans"; package = pkgs.noto-fonts; };
    serif = { family = "Noto Serif"; package = pkgs.noto-fonts; };
    monospace = { family = "Iosevka"; package = _iosevka; };
    fallback = { family = "Font Awesome 5 Free"; package = pkgs.font-awesome; };
    emoji = { family = "Noto Color Emoji"; package = pkgs.noto-fonts-emoji; };
    
    allPackages = (map (p: p.package) [ default sans serif monospace fallback emoji ]) ++
      (with pkgs; [
        liberation_ttf # free corefonts-metric-compatible replacement
        ttf_bitstream_vera
        gelasio
      ]);
  };
}
