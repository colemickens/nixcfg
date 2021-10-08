{ pkgs, config, ... }:

let
  hostname = "oraprox";
in {
  imports = [
    ../../mixins/common.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/tailscale-autoconnect.nix

    ../../profiles/user.nix

    ./wg-rev-proxy.nix
  ];
  config = {
    networking.hostName = hostname;

    # we could run two different nixos containers
    # -> one serves the public cleo image and the links to the internal VPN services
    # -> one is the actual frontend bound on the wg0 interface
  };
}
