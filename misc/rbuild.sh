#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
set -x

cachix_cache="colemickens"
cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"

function nix() { "${DIR}/nix.sh" "${@}"; }

remote="${1}"; shift
target="${1}"; shift
thing="${1}"; shift

name="$(echo "${thing}" | cut -d'#' -f2-)"

# TODO: consider removing the rest of the script
# TODO: consider if we want to have rbuild copy locally and ractivate tries to do direct??
# or just have an option that pushes this straight to cachix and skips copy to target...
cachix=0
# TODO: instead use env vars?
# RBUILD_MODE=="direct"
# RBUILD_MODE=="cachix"
if [[ "${target}" != "cachix" ]]; then
  nix copy \
    --eval-store "auto" \
    --no-check-sigs \
    --derivation \
    --to "ssh-ng://${remote}" \
    "${thing}" "${@}"
  nix copy \
    --eval-store "auto" \
    --no-check-sigs \
    --from "ssh-ng://${remote}" \
    --no-check-sigs \
    --to "ssh-ng://${target}" \
    --no-check-sigs \
      "${thing}" "${@}" >/dev/stderr
else
  nix build \
    --keep-going \
    --eval-store "auto" \
    --no-check-sigs \
    --from "ssh-ng://${remote}" \
    --to "ssh-ng://${target}" \
      "${thing}" "${@}" >/dev/stderr
fi

_out="$(nix eval --raw "${thing}")"
printf "%s" "${_out}" > /tmp/out
ssh "${remote}" "echo \"${_out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" cachix push ${cachix_cache} >/dev/stderr" >/dev/stderr &

echo "${_out}"

exit 0






























## find out our fate
# TODO: try --eval --derivation?
# drv="$(nix eval --raw --derivation "${thing}.drvPath" "${@}")"
# out="$(nix-store --query ${drv})"

# TODO: try: nix show-derivation | jq -r '.[].outputs.out.path' # https://github.com/NixOS/nix/issues/5895#issuecomment-1009370544

## copy up drvs
nix copy \
  --derivation \
  --eval-store "auto" \
  --no-check-sigs \
  --to "ssh-ng://${remote}" \
    "${thing}" >/dev/stderr

## build and copy back

nix build -L --eval-store "auto" --json \
  --store "ssh-ng://${remote}" \
  --keep-going \
  "${thing}" "${@}" >"/tmp/nb-stdout-${name}"

# nix build -L --eval-store "auto" \
#   --store "ssh-ng://${remote}" \
#   --keep-going \
#   "${thing}" "${@}" >/dev/stderr

out="$(cat "/tmp/nb-stdout-${name}" | jq -r .[0].outputs.out)"

nix copy --eval-store "auto" --no-check-sigs \
  --from "ssh-ng://${remote}" \
  --to "ssh-ng://${target}" \
  "${thing}" "${@}" >/dev/stderr

## (if we're wanting cachix, go ahead and run the push in the background)
ssh "${remote}" "echo \"${out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" cachix push ${cachix_cache} >/dev/stderr" >/dev/stderr &

#### whew
echo "done" > /dev/stderr
echo "${out}" > /dev/stdout
