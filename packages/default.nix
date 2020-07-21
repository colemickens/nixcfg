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
};
in
  colePackages // { inherit colePackages; }