#!/usr/bin/env bash
set -euo pipefail
set -x

if [[ ! -f /etc/nixos/original.nix ]]; then
  mv /etc/nixos/configuration.nix /etc/nixos/original.nix || true
fi

nix-env -iA cachix -f https://github.com/NixOS/nixpkgs/tarball/889c72032f8595fcd7542c6032c208f6b8033db6

function write-config() {
cat<<EOF >"/etc/nixos/configuration.nix"
  { lib, pkgs, ... }:

  {
    imports = [ ./original.nix ];
    nix = {
      buildCores = 0;
      binaryCachePublicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "colemickens.cachix.org-1:oIGbn9aolUT2qKqC78scPcDL6nz7Npgotu644V4aGl4="
        "nixpkgs-colemickens.cachix.org-1:mPLfhD5O77PMiEfiUy5rMHeIURcmvwQGevAms+bak9w="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nixpkgs-kubernetes.cachix.org-1:FtZMc4acxfHbDZBkWcOJ86Cji2bT6z8mx90gcS/72FQ="
      ];
      binaryCaches = [
        "https://cache.nixos.org"
        "https://colemickens.cachix.org"          # my system builds
        "https://nixpkgs-colemickens.cachix.org"  # my personal overlay
        "https://nixpkgs-wayland.cachix.org"      # my overlay with wayland stuff
        "https://nixpkgs-kubernetes.cachix.org"   # my overlay with kubernetes stuff
      ];
    };
  }
EOF
}

write-config
nixos-rebuild switch

nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
nixos-rebuild boot

reboot

