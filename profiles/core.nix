{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./user.nix
    ../mixins/common.nix

    ../mixins/sshd.nix
    ../mixins/tailscale.nix
  ];

  config = { };
}
