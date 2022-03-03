{ pkgs, lib, config, inputs, ... }:

let
  hostColor = "blue1";
in
{
  imports = [
    ./user.nix
    inputs.home-manager.nixosModules."home-manager"
    ../mixins/common-hm.nix

    ../mixins/common.nix

    ../mixins/git.nix
    ../mixins/ssh.nix
    ../mixins/zsh.nix

    ../mixins/helix.nix
    ../mixins/zellij.nix
  ];

  # gpg --pinentry-mode loopback --batch --passphrase '' --quick-generate-key "testkeyrpione"

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.cole = { pkgs, ... }: {
      home.stateVersion = "20.03";
      home.sessionVariables = {
        EDITOR = "nvim";
      };
      manual = { manpages.enable = false; };
      news.display = "silent";
      programs = {
        home-manager.enable = true;
        gpg.enable = true;
      };
      home.packages = with pkgs; [
        git-crypt
        bottom
      ];
    };
  };
}
