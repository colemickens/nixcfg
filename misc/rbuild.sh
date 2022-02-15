#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
set -x

cachix_cache="colemickens"
cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"

function nix() { "${DIR}/nix.sh" "${@}"; }

# {copy_method} {activate_action} {remote_builder} {target} {thing}

remote="${1}"; shift
target="${1}"; shift
thing="${1}"; shift


## find out our fate
# TODO: try --eval --derivation?
drv="$(nix eval --raw --derivation "${thing}.drvPath" "${@}")"
out="$(nix-store --query ${drv})"

# TODO: try: nix show-derivation | jq -r '.[].outputs.out.path' # https://github.com/NixOS/nix/issues/5895#issuecomment-1009370544

## copy up drvs
nix copy \
  --derivation \
  --eval-store "auto" \
  --no-check-sigs \
  --to "ssh-ng://${remote}" \
    "${drv}" >/dev/stderr

## build and copy back
nix build -L --eval-store "auto" \
  --store "ssh-ng://${remote}" \
  --keep-going \
  "${thing}" "${@}" >/dev/stderr

nix copy --eval-store "auto" --no-check-sigs \
  --from "ssh-ng://${remote}" \
  --to "ssh-ng://${target}" \
  "${thing}" "${@}" >/dev/stderr

## (if we're wanting cachix, go ahead and run the push in the background)
ssh "${remote}" "echo \"${out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" cachix push ${cachix_cache} >/dev/stderr" >/dev/stderr &

#### whew
echo "done" > /dev/stderr
echo "${out}" > /dev/stdout
