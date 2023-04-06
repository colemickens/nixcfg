{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./user-cole.nix
    ../mixins/common.nix

    ../mixins/sshd.nix
    ../mixins/tailscale.nix
  ];

  config = { };
}
