{ ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./configuration-base.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
  };
}
