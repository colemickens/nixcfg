{ config, pkgs, lib, modulesPath, ... }:

let
  hn = "installer-nvidia-ai";
in
{
  imports = [
    ./configuration-base.nix

    ../../mixins/gfx-nvidia.nix

    # ../../profiles/gui-sway-auto.nix
    ../../profiles/addon-ai-nvidia.nix
  ];

  config = {
    networking.hostName = hn;
    system.nixos.tags = [ "nvidia-ai" ];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "nvidia-x11" # for `gfx-nvidia.nix`
      "google-chrome" # for `gui-sway.nix`
      "google-chrome-120.0.6099.216" # for `gui-sway.nix`
    ];
  };
}
