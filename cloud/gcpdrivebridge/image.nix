{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/google-compute-image.nix"
    ../../modules/loremipsum-media/rclone-cmd.nix

    ../../modules/user-cole.nix
  ];

  virtualisation.googleComputeImage.diskSize = 2000;

  system.stateVersion = "19.09";
  networking.hostName = "gcpdrivebridge";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  #environment.noXlibs = true;
  #documentation.enable = false;
  #documentation.nixos.enable = false;

  services.openssh.passwordAuthentication = false;
  programs.mosh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    neovim ripgrep wget curl tmux aria2 megatools plowshare
  ];

  nix.allowedUsers = [ "root" "@wheel" "cole_mickens_gmail_com" "cole" ];
  nix.trustedUsers = [ "root" "@wheel" "cole_mickens_gmail_com" "cole" ];
}
