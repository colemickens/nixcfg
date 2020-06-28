self: pkgs:

{
  customCommands = pkgs.callPackages ./commands.nix {};
  customGuiCommands = pkgs.callPackages ./commands-gui.nix {};
  mirage-im = pkgs.callPackage ./mirage-im.nix {};
  neovim-unwrapped = pkgs.callPackage ./neovim.nix {
    neovim-unwrapped = pkgs.neovim-unwrapped;
  };
  nheko = pkgs.callPackage ./nheko.nix {};
  passrs = pkgs.callPackage ./passrs.nix {};
}
