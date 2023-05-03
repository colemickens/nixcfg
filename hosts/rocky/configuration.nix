{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/interactive.nix
  ];
  environment.systemPackages = with pkgs; [
    picocom
    rkdeveloptool
    rkflashtool
  ];
}
