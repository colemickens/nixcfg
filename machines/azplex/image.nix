{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    "${modulesPath}/virtualisation/azure-image.nix"
    ../../modules/loremipsum-media/rclone-mnt.nix
    ../../modules/mixin-plex.nix
    ../../modules/mixin-srht-cronjobs.nix
    ../../modules/user-cole.nix
  ];

  nix.nixPath = [
    "nixpkgs=/home/cole/code/nixpkgs"
    "nixos-config=/home/cole/code/machines/azplex/image.nix"
  ];

  virtualisation.azureImage.diskSize = 2500;
  virtualisation.docker.enable = true;

  system.stateVersion = "19.09";
  networking.hostName = "azplex";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #environment.noXlibs = true;
  #documentation.enable = false;
  #documentation.nixos.enable = false;

  services.openssh.passwordAuthentication = false;
  programs.mosh.enable = true;

  security.sudo.wheelNeedsPassword = false;
    
  environment.systemPackages = with pkgs; [
    git neovim jq file htop ripgrep cachix wget curl tmux
  ];

  nix.allowedUsers = [ "root" "@wheel" "azureuser" "cole" ];
  nix.trustedUsers = [ "root" "@wheel" "azureuser" "cole" ];
}
