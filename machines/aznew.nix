{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    ../modules/mixin-loremipsum-media.nix
    ../modules/mixin-plex.nix
  ];

  programs.mosh.enable = true;
  #virtualisation.docker.enable = true;
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ git neovim jq file htop ripgrep cachix wget curl tmux ];

  nix.allowedUsers = [ "root" "azureuser" ];
  nix.trustedUsers = [ "root" "azureuser" ];
}
