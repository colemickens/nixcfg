{ lib, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./configuration-base.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
  };
}
