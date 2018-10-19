{ config, lib, pkgs, ... }:

{
  config = {
    virtualisation.libvirtd = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      virtviewer
      virt-manager
    ];
  };
}

