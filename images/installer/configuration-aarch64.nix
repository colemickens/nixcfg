{ lib, ... }:

{
  imports = [
    ./configuration-base.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
  };
}
