{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ./unfree.nix
    # TODO: we can /probably/ do better, not even that hard to imagine
    # - migrate profiles to modules, enable/disable, lots of things get easier
    # NOTE: to make it simple, pick one or the other
    # ./bootstrap.nix
    ./full.nix # includes bootstrap.nix
  ];
  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
  };
}
