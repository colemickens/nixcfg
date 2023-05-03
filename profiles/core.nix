{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./user-cole.nix
    ./hm.nix
    ../mixins/common.nix

    ../mixins/sshd.nix
    ../mixins/gpg-agent.nix
    ../mixins/tailscale.nix

    ../mixins/bottom.nix
    ../mixins/helix.nix
    # doesn't cross-compile, can't be in core:
    # ../mixins/zellij.nix
  ];

  config = { };
}
