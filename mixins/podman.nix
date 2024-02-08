{ config, ... }:

{
  config = {
    virtualisation = {
      # see hosts/zeph/configuration.nix for the zfs dataset mounted to /var/lib/containers/storage
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };
  };
}
