{ pkgs, lib, ... }:

{
  imports = [
    ./system.nix
    ../../profiles/interactive.nix
    ../../mixins/oavm-risky.nix
  ];
  
  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";

    nix.settings = {
      max-jobs = 10;
      cores = 8;
    };

    nixcfg.common.autoHostId = false;
    nixcfg.common.addLegacyboot = false;
  };
}
