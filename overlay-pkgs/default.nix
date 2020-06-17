self: pkgs:

{
  neovim = pkgs.callPackage ./neovim.nix {};
  passrs = pkgs.callPackage ./passrs.nix {};
}
