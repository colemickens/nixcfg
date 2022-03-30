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

_drv="$(nix eval --raw --derivation "${thing}.drvPath" "${@}")"
_out="$(nix-store --query "${_drv}"  2>/dev/null)"
printf "\n_drv=%s\n_out=%s\n" "${_drv}" "${_out}" >&2

cachix=0

printf '\n%s\n' ">>> copy derivations" >&2
set -x;
nix copy \
  --eval-store "auto" \
  --no-check-sigs \
  --derivation \
  --to "ssh-ng://${remote}" \
  "${_drv}"; set +x;
  #"${thing}" "${@}"; set +x;

if [[ "${target}" != "cachix" ]]; then
  printf '\n%s\n' ">>> build/copy outputs" >&2
  set -x;
  nix copy \
    --builders-use-substitutes \
    --eval-store "auto" \
    --no-check-sigs \
    --from "ssh-ng://${remote}" \
    --to "ssh-ng://${target}" \
      "${_drv}" "${@}" >/dev/stderr
  set +x;
else
  printf '\n%s\n' ">>> build outputs remote" >&2
  set -x;
  nix build \
    --builders-use-substitutes \
    --keep-going \
    --eval-store "auto" \
    --store "ssh-ng://${remote}" \
      "${_drv}" "${@}" >&2
  set +x;
fi

if [[ "${SKIP_CACHIX:-""}" != "1" ]]; then
  printf '\n%s\n' ">>> push to cachix from remote" >/dev/stderr
  ssh "${remote}" "echo \"${_out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" tee /dev/stderr | cachix push ${cachix_cache} >/dev/stderr" >&2
fi

printf '%s' "${_out}"

exit 0






























## find out our fate
# TODO: try --eval --derivation?
# drv="$(nix eval --raw --derivation "${thing}.drvPath" "${@}")"
# out="$(nix-store --query ${_drv})"

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
ssh "${remote}" "echo \"${_out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" cachix push ${cachix_cache} >/dev/stderr" >/dev/stderr &

#### whew
echo "done" > /dev/stderr
echo "${_out}" > /dev/stdout
