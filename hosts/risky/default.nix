{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    "${inputs.riscv64}/nixos/visionfive.nix"
  ];

  config = {
    # this riscv64 nixos module pulls its own overlay in
    # nixpkgs.overlays = [
    #   inputs.riscv64.overlay
    # ];
    
    # disk
    # timezone override?
    # ?
  };
}
