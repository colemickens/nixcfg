{ lib, ... }:

let
  hn = "installer-standard";
in
{
  imports = [
    ./configuration-base-installer.nix

    ../../profiles/interactive.nix
  ];

  config = {
    networking.hostName = hn;
    system.nixos.tags = [ "standard" ];

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        ### misc
        "nvidia-x11"
      ];
  };
}
