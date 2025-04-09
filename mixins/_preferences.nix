{ pkgs, inputs, ... }:

let
  # colorscheme = inputs.nix-rice.colorschemes."purplepeter";
  # colorscheme = inputs.nix-rice.colorschemes."GruvboxDark";
  # colorscheme = inputs.nix-rice.colorschemes."Builtin Tango Dark";
  # colorscheme = inputs.nix-rice.colorschemes."Wombat";
  # colorscheme = inputs.nix-rice.colorschemes."ayu";
  # colorscheme = inputs.nix-rice.colorschemes."flexoki-dark";
  # colorscheme = inputs.nix-rice.colorschemes."iTerm2 Tango Dark";
  colorscheme = inputs.nix-rice.colorschemes."MaterialDarker";

  colordefs = {
    bold_as_bright = false;
  };
in
rec {
  # all configured with HM, so just use binary name
  editor = "hx";
  default_term = "alacritty";
  default_shell = "nu";

  gtk = {
    font = {
      name = "${font.default.family} 11";
      package = font.default.package;
    };
    preferDark = true;

    # iconTheme = { name = "Numix Circle"; package = pkgs.numix-icon-theme; };
    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };
    # T # iconTheme = { name = "Fluent"; package = pkgs.fluent-icon-theme; };
    # T # iconTheme = { name = "Colloid"; package = pkgs.colloid-icon-theme; };
    # iconTheme = { name = "WhiteSur-dark"; package = pkgs.whitesur-icon-theme; };
    # T # iconTheme = { name = "McMojave-circle"; package = pkgs.mcmojave-icon-theme; };

    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    # theme = { name = "Orchis-purple-dark-compact"; package = pkgs.orchis-theme; };
    # theme = { name = "WhiteSur-dark-solid"; package = pkgs.whitesur-gtk-theme; };
    # theme = { name = "Mojave-dark-solid"; package = pkgs.mojave-gtk-theme; };
    #ew # theme = { name = "Marwaita Color Dark"; package = pkgs.marwaita; };
    # theme = { name = "Qogir-dark"; package = pkgs.qogir-theme; };
  };

  ## cursor
  # cursor = { name = "capitaine-cursors-white"; package = pkgs.capitaine-cursors; };
  # cursor = { name = "Bibata-Original-Amber"; package = pkgs.bibata-cursors; };
  # cursor = { name = "Catppuccin-Latte-Pink-Cursors"; package = pkgs.catppuccin-cursors.lattePink; };
  cursor = {
    name = "macOS-White";
    package = pkgs.apple-cursor;
  };
  cursorSize = 48;

  themes = {
    alacritty = colorscheme // colordefs;
    sway = colorscheme // colordefs;
    wezterm = colorscheme // colordefs;
    zellij = colorscheme // colordefs;
  };
  inherit colorscheme;

  bgcolor = "#00807F";
  sway_background = "${bgcolor} solid_color";
  swaylock_background =
    let
      gruvbox_rainbow = {
        image =
          (builtins.fetchurl {
            url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/0797f8f90a440fbc1c0a412c133e4814034b0b50/png/gruvbox-dark-rainbow-square.png";
            sha256 = "1qggwqx0flqxk0ckv4x0a1gbhpchbaqvlpm8xc7xys1kbgwh4d45";
          }).outPath;
        scaling = "fit";
        color = "282828";
      };
      nix_glow = {
        image =
          (pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/gytis-ivaskevicius/high-quality-nix-content/master/wallpapers/nix-glow.png";
            hash = "sha256-5zE0fRfudEW9eapx+AkaYArO6ECFrnrNHE+een7pC+E=";
          }).outPath;
        scaling = "fit";
        color = "19191A";
      };
    in
    nix_glow;

  # wallpaper = bg_gruvbox_rainbow;

  swayfonts = {
    names = [
      font.default.family
      font.fallback.family
    ];
    style = "Heavy";
    size = 10.0;
  };

  font = rec {
    size = 12;
    default = sans;

    sans = {
      family = "Noto Sans";
      package = pkgs.noto-fonts;
    };
    serif = {
      family = "Noto Serif";
      package = pkgs.noto-fonts;
    };

    monospace = {
      family = "Iosevka Fixed";
      package = pkgs.iosevka-bin;
    };
    # monospace = { family = "Iosevka Comfy Fixed"; package = pkgs.iosevka-comfy.comfy-fixed; };
    # monospace = { family = "Iosevka Comfy Motion"; package = pkgs.iosevka-comfy.comfy-motion; };

    fallback = {
      family = "Font Awesome 5 Free";
      package = pkgs.font-awesome;
    };
    emoji = {
      family = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };

    allPackages =
      (map (p: p.package) [
        default
        sans
        serif
        monospace
        fallback
        emoji
      ])
      ++ (with pkgs; [
        liberation_ttf # free corefonts-metric-compatible replacement
        ttf_bitstream_vera
        gelasio # metric-compatible with Georgia
        powerline-symbols
        intel-one-mono
        commit-mono
        comic-mono
        open-sans
        nebula-sans
        departure-mono
        lexend
        iosevka-bin
        iosevka-comfy.comfy-fixed # always include our favesies
        iosevka-comfy.comfy-motion # always include our favesies
      ]);
  };
}
