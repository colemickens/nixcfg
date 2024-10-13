{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    ./gui-wayland.nix
    # ../mixins/i3status-rust.nix
    ../mixins/gtk.nix
    ../mixins/kanshi.nix
    ../mixins/mako.nix
    ../mixins/waybar.nix
  ];
  config = {
    # how to setup gamescope session autologin with some tiny-ass resolution for this sad igpu

    # auto-run tty for gamescope
  };
}
