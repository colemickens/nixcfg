#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail

cachix_cache="colemickens"
cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"

function nix() { "${DIR}/nix.sh" "${@}"; }

out="${1}"; shift
target="${1}"; shift
action="${1:-"sw"}";

if [[ "${action:-""}" == *sw* ]]; then
  printf '\n%s\n' ">>> link system-profile (${target})" >&2
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --no-link --profile /nix/var/nix/profiles/system "${out}")"
  printf '\n%s\n' ">>> switch-to-configuration (${target})" >&2
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${out}" -c switch-to-configuration switch)"
fi

if [[ "${action:-""}" == *rs* ]]; then ssh "${target}" "sudo reboot"; fi

#### whew
printf '%s' "${out}" > /dev/stdout
