{ pkgs, inputs, ... }:

let
  colorscheme = inputs.nix-rice.colorschemes."purplepeter";

  bg_gruvbox_rainbow = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/master/png/gruvbox-dark-rainbow.png";
    sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
  };
  default_color_settings = {
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

  cursor = { name = "captaine-cursors"; package = pkgs.capitaine-cursors; };
  # cursor = { name = "capitaine-cursors"; package = pkgs.capitaine-cursors; };
  # cursor = { name = "adwaita"; package = pkgs.gnome3.adwaita-icon-theme; };
  # cursor = { name = "breeze-cursors"; package = pkgs.breeze-icons; };
  themes = {
    alacritty = colorscheme;
    sway = colorscheme;
    wezterm = colorscheme;
    zellij = colorscheme;
  };
  inherit colorscheme;

  bgcolor = "#000000";
  background = "${bgcolor} solid_color";
  # background = "${bg_gruvbox_rainbow} center #333333";
  wallpaper = bg_gruvbox_rainbow;

  font = rec {
    size = 13;
    default = { family = "Iosevka"; package = _iosevka; };
    fallback = { family = "Font Awesome 5 Free"; package = pkgs.font-awesome; };
    emoji = { family = "Noto Sans Emoji"; package = pkgs.noto-fonts-emoji; };
    extraPackages = with pkgs; [ corefonts ttf_bitstream_vera gelasio noto-fonts ];
    allPackages = [ default fallback emoji ] ++ extraPackages;
  };
  colors = {
    default = default_color_settings // colorscheme;
  };
}
