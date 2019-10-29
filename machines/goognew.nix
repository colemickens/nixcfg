{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/google-compute-image.nix"
    ../modules/mixin-loremipsum-media.nix
    #../modules/mixin-plex.nix
  ];

  system.stateVersion = "19.03";

  programs.mosh.enable = true;
  #virtualisation.docker.enable = true;
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ git neovim jq file htop ripgrep cachix wget curl tmux ];

  nix.allowedUsers = [ "root" "cole_mickens_gmail_com" ];
  nix.trustedUsers = [ "root" "cole_mickens_gmail_com" ];
}
