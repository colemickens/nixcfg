{ pkgs, inputs, ... }:
let
  hostname = "pinebook";
in
{
  imports = [
    inputs.mobile-nixos.devices.pine64-pinephone
  ] ++ inputs.mobile-nixos.nixosModules;

  config = {
      # https://github.com/Dejvino/pinephone-sway-poc
      # package: https://git.sr.ht/~mil/lisgd
      # https://aur.archlinux.org/packages/squeekboard/
      # https://github.com/efernau/rot8
  };
}

# https://patchwork.ozlabs.org/project/uboot/patch/20200619121657.180850-1-icenowy@aosc.io/
