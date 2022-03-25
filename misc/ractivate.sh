#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail

cachix_cache="colemickens"
cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"

function nix() { "${DIR}/nix.sh" "${@}"; }

  nixargs=(
    --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org'
    --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso='
    --option 'build-cores' '0'
    --option 'narinfo-cache-negative-ttl' '0'
    --builders-use-substitutes
  )

out="${1}"; shift
target="${1}"; shift
action="${1:-"sw"}";

if [[ "${action:-""}" == *sw* ]]; then
  printf '\n%s\n' ">>> link system-profile (${target})" >&2
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --no-link --profile /nix/var/nix/profiles/system "${out}")"
  printf '\n%s\n' ">>> switch-to-configuration (${target})" >&2
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${out}" -c switch-to-configuration switch)"
  if [[ "${NIXOS_INSTALL:-""}" == "1" ]]; then
    ssh "${target}" "$(printf '\"%s\" ' sudo nixos-install --no-root-passwd --root / "${nixargs[@]}" --system "${out}")"
  fi
fi

if [[ "${action:-""}" == *rs* ]]; then ssh "${target}" "sudo reboot"; fi

#### whew
printf '%s' "${out}" > /dev/stdout
