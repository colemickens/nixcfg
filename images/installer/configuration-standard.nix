{ lib, inputs, ... }:

let
  hn = "installer-standard";
in
{
  imports = [
    inputs.determinate.nixosModules.default

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
