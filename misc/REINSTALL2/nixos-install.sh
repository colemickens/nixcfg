#! /usr/bin/env bash
set -x

install_system=$1
MOUNTPT="/mnt-install"

allargs=(
  "${allargs[@]}"
  --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org'
  --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso='
  --option 'build-cores' '0'
  --option 'narinfo-cache-negative-ttl' '0'
)

nix copy --to "${MOUNTPT}" "${install_system}"

sudo nixos-enter \
  --root "${MOUNTPT}" \
  --command "${cmd}"
  
sudo nixos-install \
  --no-channel-copy \
  --root "${MOUNTPT}" \
  --system "${install_system}" \
  --no-root-passwd \
  "${allargs[@]}"
