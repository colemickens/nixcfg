{ config, lib, pkgs, inputs, ... }:

{
  config = {
    nixpkgs.overlays = [
      (self: super: {
        lua51Packages = super.lua51Packages.extend (_: lsuper: {
          plenary-nvim = lsuper.plenary-nvim.overrideAttrs (_: {
            knownRockspec = (self.fetchurl {
              url = "https://raw.githubusercontent.com/nvim-lua/plenary.nvim/master/plenary.nvim-scm-1.rockspec";
              sha256 = "08kv1s66zhl9amzy9gx3101854ig992kl1gzzr51sx3szr43bx3x";
            });
          });
        });
      })
    ];
  };
}
