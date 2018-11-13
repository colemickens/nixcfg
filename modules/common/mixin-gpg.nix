{ config, lib, pkgs, ... }:

{
  services = {
    pcscd.enable = true;
  };

  environment.systemPackages = with pkgs; [ gnupg ];
  programs.gnupg.agent = {
    enable = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };
}

