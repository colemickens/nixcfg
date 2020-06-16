{ pkgs, config, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    "${modulesPath}/virtualisation/azure-image.nix"

    ../../config-nixos/loremipsum-media/rclone-mnt.nix
    ../../config-nixos/loremipsum-media/rclone-cmd.nix
    ../../config-nixos/mixin-plex.nix
    ../../config-nixos/mixin-cachix.nix

    ../../config-home/users/cole/core.nix
  ];

  config = {
    virtualisation.azureImage.diskSize = 2500;

    system.stateVersion = "20.03";
    networking.hostName = "azdev";
    boot.kernelPackages = pkgs.linuxPackages_latest;

    nix.nrBuildUsers = 100;
    #nix.package = pkgs.nixUnstable;

    #environment.noXlibs = true;
    #documentation.enable = false;
    documentation.nixos.enable = false;

    services.openssh.passwordAuthentication = false;
    programs.mosh.enable = true;

    security.sudo.wheelNeedsPassword = false;

    environment.systemPackages = with pkgs; [
      git
      neovim
      jq
      file
      htop
      ripgrep
      wget
      curl
      tmux
    ];

    nix.allowedUsers = [ "root" "@wheel" "azureuser" "cole" ];
    nix.trustedUsers = [ "root" "@wheel" "azureuser" "cole" ];
  };
}
