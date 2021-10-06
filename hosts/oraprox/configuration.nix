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
  };
}
