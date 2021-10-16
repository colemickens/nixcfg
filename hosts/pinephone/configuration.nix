{ pkgs, config, inputs, ... }:

let
  hostname = "pinephon4";
in
{
  imports = [
    ../../profiles/user.nix
    #../../profiles/interactive.nix
    #../../modules/loginctl-linger.nix
    #../../mixins/common.nix
    ../../mixins/sshd.nix
    #../../mixins/tailscale.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })
  ];

  config = {
      # https://github.com/Dejvino/pinephone-sway-poc
      # package: https://git.sr.ht/~mil/lisgd
      # https://aur.archlinux.org/packages/squeekboard/
      # https://github.com/efernau/rot8

      #users.users.cole.linger = true;

      networking.hostName = hostname;

      users.extraUsers."demo" = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = (import ../data/sshkeys.nix);
        #mkpasswd -m sha-512
        hashedPassword = "$6$Q3FVuYDM$.W.cnGu2HJpF0jPc36WG7uxWr8APu6/fWe3M7LGUOkYrL3/XcEbKv/5r4VjTd6ARcStRBNHvSB1QxaAtRRp9B/";
        uid = 1010;
      };

      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ inputs.self.overlay ];

      ### BEGIN HACKY COPY
  };
}

# https://patchwork.ozlabs.org/project/uboot/patch/20200619121657.180850-1-icenowy@aosc.io/
