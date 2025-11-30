{ ... }:

{
  imports = [
    ./user-cole.nix
    ./user-deploy.nix
    ./hm.nix

    ../mixins/common.nix

    ../mixins/sshd.nix
    ../mixins/gpg-agent.nix
    ../mixins/tailscale.nix

    ../mixins/cargo.nix
  ];

  config = { };
}
