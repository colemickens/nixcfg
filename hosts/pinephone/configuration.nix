{ pkgs, inputs, ... }:
let
  hostname = "pinephone";
in
{
  imports = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })

    # "${inputs.mobile-nixos}/devices/pine64-pinephone/default.nix"

    #../../profiles/interactive.nix
    ../../mixins/common.nix
    
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
  ]; #++ (import "${inputs.mobile-nixos}/modules/module-list.nix");

  config = {
      # https://github.com/Dejvino/pinephone-sway-poc
      # package: https://git.sr.ht/~mil/lisgd
      # https://aur.archlinux.org/packages/squeekboard/
      # https://github.com/efernau/rot8

      networking.hostName = "pinephone";

      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ inputs.self.overlay ];

      ### BEGIN HACKY COPY
  };
}

# https://patchwork.ozlabs.org/project/uboot/patch/20200619121657.180850-1-icenowy@aosc.io/
