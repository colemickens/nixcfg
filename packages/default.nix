self: pkgs:

let colePackages = {
  customCommands = pkgs.callPackages ./commands.nix {};
  customGuiCommands = pkgs.callPackages ./commands-gui.nix {};

  alps = pkgs.callPackage ./alps {};
  mirage-im = pkgs.libsForQt5.callPackage ./mirage-im {};
  neovim-unwrapped = pkgs.callPackage ./neovim {
    neovim-unwrapped = pkgs.neovim-unwrapped;
  };
  passrs = pkgs.callPackage ./passrs {};

  raspberrypi-eeprom = pkgs.callPackage ./raspberrypi-eeprom {};
  
  rpi4-uefi = pkgs.callPackage ./rpi4-uefi {};

  cchat-gtk = pkgs.callPackage ./cchat-gtk {
    libhandy = pkgs.callPackage ./libhandy {};
  };

  obs-v4l2sink = pkgs.libsForQt5.callPackage ./obs-v4l2sink {};
};
in
  colePackages // { inherit colePackages; }