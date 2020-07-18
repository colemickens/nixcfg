self: pkgs:

let colePackages = {
  customCommands = pkgs.callPackages ./commands.nix {};
  customGuiCommands = pkgs.callPackages ./commands-gui.nix {};

  alps = pkgs.callPackage ./alps {};
  mirage-im = pkgs.callPackage ./mirage-im {};
  neovim-unwrapped = pkgs.callPackage ./neovim {
    neovim-unwrapped = pkgs.neovim-unwrapped;
  };
  nyxt = pkgs.callPackage ./nyxt {};
  passrs = pkgs.callPackage ./passrs {};
};
in
  colePackages // { inherit colePackages; }