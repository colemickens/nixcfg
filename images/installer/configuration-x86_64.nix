{ ... }:

{
  imports = [
    ./configuration-base.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
  };
}
