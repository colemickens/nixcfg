{ config, lib, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      # TODO: confirm, unused?
      # "unifi-controller"
      # "plexmediaserver"
      # "mongodb"
    ];
  };
}
