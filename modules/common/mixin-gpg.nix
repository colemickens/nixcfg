{ config, lib, pkgs, ... }:

{
  services = {
    pcscd.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}

