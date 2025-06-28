{ pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
    virtualisation.docker = {
      enable = true;
      #storageDriver = "zfs";

      # we don't use long running docker containers, start on socket
      enableOnBoot = false;
    };
  };
}
