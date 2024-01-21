{ config, pkgs, lib, modulesPath, ... }:

let
  hn = "installer-cosmic";
in
{
  imports = [
    ./configuration-base.nix

    ../../profiles/gui-cosmic.nix
  ];

  config = {
    networking.hostName = hn;
    system.nixos.tags = [ "cosmic" ];

    # probably only works with mesa-y platforms (so, no nvidia)
    hardware.opengl.enable = true;

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      ### misc
      "google-chrome"
      "google-chrome-dev"

      "google-chrome-120.0.6099.216" # uh, why is it suddenly making me include version?
    ];
  };
}

