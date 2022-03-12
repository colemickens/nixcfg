{ pkgs, inputs, ... }:

let
  iterm_cs = "purplepeter";
  #iterm_cs = "Builtin Tango Dark";
  #iterm_cs = "Builtin Solarized Dark";

  colorscheme = inputs.nix-rice.colorschemes.${iterm_cs};

  bg_gruvbox_rainbow = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/master/png/gruvbox-dark-rainbow.png";
    sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
  };
  default_color_settings = {
    bold_as_bright = true;
  };
  lockcmd = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --effect-scale 0.5 --effect-blur 7x5 --effect-scale 2 --effect-pixelate 10";
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  idlecmd = pkgs.writeShellScript "swayidle.sh" ''
    pkill swayidle
    # TODO: pgrep
    exec swayidle -w \
        timeout 300 "${lockcmd}" \
        timeout 330 "${swaymsg} \"output * dpms off\"" \
        resume "${swaymsg} \"output * dpms on\"" \
        timeout 30 "if pgrep swaylock; then ${swaymsg} \"output * dpms off\"; fi" \
        resume "if pgrep swaylock; then ${swaymsg} \"output * dpms on\"; fi" \
        before-sleep "${lockcmd}"
  '';
in
{
  # all configured with HM, so just use binary name
  editor = "hx";
  shell = { program = "nu"; args = []; };
  default_term = "alacritty";
  default_launcher = "sirula";
  xwayland_enabled = true;
    
  aliases = {
    "pw" = "prs show";
  };

  poststart = pkgs.writeShellScript "poststart.sh" ''
    systemctl import-environment --user WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_SESSION_ID
  '';

  lockcmd = lockcmd;
  idlelockcmd = "${lockcmd} --fade-in 10 --grace 10";
  idlecmd = idlecmd;

  bgcolor = "#000000";
  wallpaper = bg_gruvbox_rainbow;

  font = {
    family = "Iosevka";
    size = 13;
    package = pkgs.iosevka;
  };
  colors = {
    default = default_color_settings // colorscheme;
  };
}
