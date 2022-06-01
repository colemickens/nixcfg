#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
function nix() { echo "==:: nix ${@}" >/dev/stderr; "${DIR}/nix.sh" "${@}"; }

export BLDR_X86="${BLDR_X86:-$(tailscale ip --6 slynux)}";
export BLDR_A64="${BLDR_A64:-"cole@pkta64.cloud.r10e.tech"}";

bldr="${1}"; shift
trgt="${1}"; shift
attr="${1}"; shift; name="$(echo "${attr}" | cut -d '#' -f2-)"

echo "=======================================================================================" >/dev/stderr
echo " BUILD: (bldr: ${bldr}) (trgt: ${trgt}) (attr: ${attr})" >/dev/stderr
echo "=======================================================================================" >/dev/stderr

_json="$(nix eval --json "${attr}" "${@}" --apply "x: { out=x.outPath; drv=x.drvPath; sys=x.system; }")"
_drv="$(echo "${_json}" | jq -r '.drv')"
_out="$(echo "${_json}" | jq -r '.out')"
_sys="$(echo "${_json}" | jq -r '.sys')"

if [[ "${bldr}" == "auto" ]]; then
  case "${_sys}" in
    "aarch64-linux") bldr="${BLDR_A64}"; ;;
    "armv6l-linux") bldr="${BLDR_X86}"; ;;
    "x86_64-linux") bldr="${BLDR_X86}"; ;;
  esac
fi

if [[ "$trgt" == *"cachix:"* ]]; then
  cachix_cache="$(echo "${trgt}" | cut -d ':' -f2)"
  trgt="cachix"
  # TODO: this is wrong:
  cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"
fi

echo "==>> ${attr}.outPath == ${_out}" >/dev/stderr


echo "==:: nix copy (derivations)"
nix copy \
  --eval-store "auto" \
  --no-check-sigs \
  --derivation \
  --to "ssh-ng://${bldr}" \
  "${_drv}"

if [[ "${trgt}" != "cachix" ]]; then
  echo "==:: nix copy (direct)"
  nix copy \
    --builders-use-substitutes \
    --eval-store "auto" \
    --no-check-sigs \
    --from "ssh-ng://${bldr}" \
    --to "ssh-ng://${trgt}" \
      "${_drv}" "${@}" >/dev/stderr
else
  echo "==:: nix build (for cachix)"
  nix build \
    --builders-use-substitutes \
    --keep-going \
    --eval-store "auto" \
    --out-link "result-${name}" \
    --store "ssh-ng://${bldr}" \
      "${_drv}" "${@}" >&2
fi

if [[ "${trgt}:-""}" == "cachix" ]]; then
  echo "==:: push to cachix"
  ssh "${bldr}" "echo \"${_out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" tee /dev/stderr | cachix push ${cachix_cache} >/dev/stderr" >&2
fi

printf '%s' "${_out}"; exit 0































## find out our fate
# TODO: try --eval --derivation?
# drv="$(nix eval --raw --derivation "${attr}.drvPath" "${@}")"
# out="$(nix-store --query ${_drv})"

# TODO: try: nix show-derivation | jq -r '.[].outputs.out.path' # https://github.com/NixOS/nix/issues/5895#issuecomment-1009370544

## copy up drvs
nix copy \
  --derivation \
  --eval-store "auto" \
  --no-check-sigs \
  --to "ssh-ng://${bldr}" \
    "${attr}" >/dev/stderr

## build and copy back

nix build -L --eval-store "auto" --json \
  --store "ssh-ng://${bldr}" \
  --keep-going \
  "${attr}" "${@}" >"/tmp/nb-stdout-${name}"

# nix build -L --eval-store "auto" \
#   --store "ssh-ng://${bldr}" \
#   --keep-going \
#   "${attr}" "${@}" >/dev/stderr

out="$(cat "/tmp/nb-stdout-${name}" | jq -r .[0].outputs.out)"

nix copy --eval-store "auto" --no-check-sigs \
  --from "ssh-ng://${bldr}" \
  --to "ssh-ng://${trgt}" \
  "${attr}" "${@}" >/dev/stderr

## (if we're wanting cachix, go ahead and run the push in the background)
ssh "${bldr}" "echo \"${_out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" cachix push ${cachix_cache} >/dev/stderr" >/dev/stderr &

#### whew
echo "done" > /dev/stderr
echo "${_out}" > /dev/stdout
