self: pkgs:

{
  customCommands = pkgs.callPackages ./commands.nix {};
  customGuiCommands = pkgs.callPackages ./commands-gui.nix {};
  neovim-unwrapped = pkgs.callPackage ./neovim.nix {
    neovim-unwrapped = pkgs.neovim-unwrapped;
  };
  passrs = pkgs.callPackage ./passrs.nix {};
}
