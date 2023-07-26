{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  pp = "lipi4a";
in
{
  imports = [
    ./inner.nix
    ./fs.nix
    ../../profiles/addon-cross.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      picocom
      rkdeveloptool
      # rkflashtool
      pulsemixer
    ];
  };
}
