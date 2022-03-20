{ pkgs, config, inputs, ... }:

let
  hostname = "pinephone";
in
{
  # TODO: check that the config works if the device
  # import comes first
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  imports = [
    ../../profiles/sway
    
    ../../modules/loginctl-linger.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })
  ];

  config = {
      #
      # TODO: investigate:
      #
      # https://github.com/Dejvino/pinephone-sway-poc
      # package: https://git.sr.ht/~mil/lisgd
      # https://aur.archlinux.org/packages/squeekboard/
      # https://github.com/efernau/rot8

      environment.systemPackages = with pkgs; [
        pipes
      ];

      users.users.cole.linger = true;

      networking.hostName = hostname;

      nixpkgs.overlays = [ inputs.self.overlay ];

      networking.wireless.enable = true;
      # nix shell 'github:nixos/nixpkgs/nixos-unstable#wpa_supplicant' \
      #   -c wpa_passphrase -- "chimera-wifi"
      networking.wireless.environmentFile = "/run/secrets/wireless.env";
      networking.wireless.networks = {
        "chimera-wifi".pskRaw = "@PSKRAW_CHIMERA_WIFI@";
      };

      ### BEGIN HACKY COPY
  };
}
