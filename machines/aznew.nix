{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    ../modules/loremipsum-media/rclone-mnt.nix
    ../modules/mixin-plex.nix
  ];

  system.stateVersion = "19.03";

  programs.mosh.enable = true;
  security.sudo.wheelNeedsPassword = false; # TODO: this should move to azure module

  environment.systemPackages = with pkgs; [ git neovim jq file htop ripgrep cachix wget curl tmux ];

  nix.allowedUsers = [ "root" "azureuser" ];
  nix.trustedUsers = [ "root" "azureuser" ];
}
