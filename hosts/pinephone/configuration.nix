{ pkgs, config, inputs, ... }:

let
  hostname = "pinephone";
in
{
  imports = [
    ../../profiles/phone.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })
  ];

  config = {
      nixcfg.common.defaultKernel = false;
      # TODO: investigate:
      # https://github.com/Dejvino/pinephone-sway-poc
      # package: https://git.sr.ht/~mil/lisgd
      # https://aur.archlinux.org/packages/squeekboard/
      # https://github.com/efernau/rot8

      networking.hostName = hostname;
  };
}
