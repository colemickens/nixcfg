{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./inner.nix
    ./fs.nix

    ../../mixins/helix.nix # try to see if helix cross compiles?
    
    ../../profiles/addon-cross.nix
    ../../profiles/gui-sway-auto.nix
  ];
}
