{ pkgs, lib, config, inputs, ... }:

let
  findImport = (import ../../../lib.nix).findImport;

  hostColor = "blue1";
  homeImport = (
    if (builtins.hasAttr "getFlake" builtins)
    then (inputs.home.nixosModules."home-manager")
    else import "${findImport "home-manager/cmhm"}/nixos"
  );
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
        neovim = import ./config/neovim-config.nix pkgs;
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
