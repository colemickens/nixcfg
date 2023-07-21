{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

{
  imports = [
    ./inner.nix
    ../../profiles/interactive.nix

    ../../mixins/pipewire.nix
  ];
  config = {
    programs.adb.enable = true;
    environment.systemPackages = with pkgs; [
      picocom
      rkdeveloptool
      rkflashtool
    ];
  };
}
