{ pkgs, lib, config, inputs, ... }:

let
  findImport = (import ../../../lib.nix).findImport;

  hostColor = "blue1";
  homeImport = (
    if (builtins.hasAttr "getFlake" builtins)
    then (inputs.home.nixosModules."home-manager")
    else homeImportLegacy
  );
  homeImportLegacy__ = findImport "home-manager/cmhm";
  homeImportLegacy_ = (import (
    fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/c75e76f80c57784a6734356315b306140646ee84.tar.gz";
      sha256 = "071aal00zp2m9knnhddgr2wqzlx6i6qa1263lv1y7bdn2w20h10h"; 
    }) {
        src =  "${homeImportLegacy__}";
    }
  ).defaultNix;
  homeImportLegacy = homeImportLegacy_.nixosModules.home-manager;
in
{
  imports = [
    # <WEIRD> This is strictly nixos stuff, but is tied to HM
    ./user.nix
    ../../../config-nixos/config/zsh-sys.nix
    # </WEIRD>
    # "${home-manager}/nixos"];
    homeImport
  ];

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.users.cole = { pkgs, ... }: {
      home.stateVersion = "20.03";
      home.sessionVariables = {
        EDITOR = "nvim";
      };
      manual = { manpages.enable = false; };
      news.display = "silent";
      programs = {
        bash  = import ./config/bash-config.nix pkgs;
        git = import ./config/git-config.nix pkgs;
        home-manager.enable = true;
        htop.enable = true;
        neovim = import ./config/neovim-config.nix { inherit pkgs inputs; };
        #starship = import ./config/starship-config.nix pkgs;
        tmux = import ./config/tmux-config.nix { inherit pkgs hostColor; };
        zsh = import ./config/zsh-config.nix { inherit pkgs; };
      };
      home.packages = with pkgs; [
        git-crypt
      ];
    };
  };
}
