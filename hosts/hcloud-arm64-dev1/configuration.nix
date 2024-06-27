{ modulesPath, config, lib, pkgs, inputs, ... }: {

  imports = [
    ../hcloud-amd64-dev1/configuration.nix
  ];

  config = {
    # wtf
    # nixpkgs.hostPlatform.system = lib.mkForce "aarch64-linux";
    nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
  };
}
