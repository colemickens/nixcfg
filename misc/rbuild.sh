#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
set -x

cachix_cache="colemickens"
cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"

function nix() { "${DIR}/nix.sh" "${@}"; }

# {copy_method} {activate_action} {remote_builder} {target} {thing}

copymethod="${1}"; shift
action="${1}"; shift
remote="${1}"; shift
target="${1}"; shift
thing="${1}"; shift

## commbox specific
"${DIR}/../misc/commbox.sh"


## find out our fate
# TODO: try --eval --derivation?
drv="$(nix eval --raw "${thing}.drvPath" "${@}")"
out="$(nix-store --query ${drv})"

# TODO: try: nix show-derivation | jq -r '.[].outputs.out.path' # https://github.com/NixOS/nix/issues/5895#issuecomment-1009370544

## copy up drvs
nix copy \
  --derivation \
  --eval-store "auto" \
  --no-check-sigs \
  --to "ssh-ng://${remote}" \
    "${drv}"

## build and copy back
nix build -L --eval-store "auto" \
  --store "ssh-ng://${remote}" \
  --keep-going \
  "${thing}" "${@}"

nix copy --eval-store "auto" --no-check-sigs \
  --from "ssh-ng://${remote}" \
  --to "ssh-ng://${target}" \
  "${thing}" "${@}"

## (if we're wanting cachix, go ahead and run the push in the background)
ssh "${remote}" "echo \"${out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" cachix push ${cachix_cache}" &


## activate it first, if requested
if [[ "${action:-""}" == *activate* ]]; then
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --no-link --profile /nix/var/nix/profiles/system "${out}")"
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${out}" -c switch-to-configuration switch)"
fi

# optimistically push to cachix
if ! wait ; then
  echo "trying to push to cachix from ${target}"
  ssh "${target}" "echo \"${out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" cachix push ${cachix_cache}" \
    || echo "**** FAILED TO PUSH TO CACHIX ****"
fi

if [[ "${action:-""}" == *reboot* ]]; then ssh "${target}" "sudo reboot"; fi

#### whew
echo "done" > /dev/stderr
echo "${out}" > /dev/stdout
