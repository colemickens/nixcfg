{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../mixins/ghostty.nix
    ../../mixins/git.nix
    ../../mixins/helix.nix
    ../../mixins/jujutsu.nix
    ../../mixins/nushell.nix
    # ../../mixins/ssh.nix
    ../../mixins/zellij.nix
  ];
  options = {
    nixcfg.common = {
      hostColor = lib.mkOption {
        type = lib.types.str;
        default = "cyan";
        description = "this is used as a hostname-hint-accent in zellij/waybar/shell prompts";
      };
    };
  };

  config = {
    nixcfg.common.hostColor = "magenta";

    home-manager.users.cole = import ../../homeManagerConfigs/cole;
    users.users.cole.home = "/Users/cole";
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    system.stateVersion = 6;

    nix.enable = false;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      kitty
      gnused
    ];

    # https://github.com/nix-community/home-manager/issues/423
    environment.variables = {
      TERMINFO_DIRS = [ "${pkgs.kitty.terminfo.outPath}/share/terminfo" ];
    };
    programs.nix-index.enable = false;

    # Fonts
    fonts.packages = with pkgs; [
      iosevka-bin
      #  recursive
      #  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    # Keyboard
    # system.keyboard.enableKeyMapping = true;
    # system.keyboard.remapCapsLockToEscape = true;

    # Add ability to used TouchID for sudo authentication
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
