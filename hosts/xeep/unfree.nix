{ config, lib, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unifi-controller"
      "plexmediaserver"

      "mongodb"
    ];
  };
}
