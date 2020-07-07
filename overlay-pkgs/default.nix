self: pkgs:

let colePackages = {
  customCommands = pkgs.callPackages ./commands.nix {};
  customGuiCommands = pkgs.callPackages ./commands-gui.nix {};

  alps = pkgs.callPackage ./alps {};
  neovim-unwrapped = pkgs.callPackage ./neovim {
    neovim-unwrapped = pkgs.neovim-unwrapped;
  };
  passrs = pkgs.callPackage ./passrs {};
};
in
  colePackages // { inherit colePackages; }