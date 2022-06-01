#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
function nix() { echo "==>> nix ${@}" >/dev/stderr; "${DIR}/nix.sh" "${@}"; }

export BLDR_X86="${BLDR_X86:-$(tailscale ip --6 slynux)}";
export BLDR_A64="${BLDR_A64:-"root@pkta64.cloud.r10e.tech"}";

bldr="${1}"; shift
trgt="${1}"; shift
attr="${1}"; shift; name="$(echo "${attr}" | cut -d '#' -f2-)"

printf "\n=============================================================================================================\n" >/dev/stderr
printf " BUILD: (bldr: ${bldr}) (trgt: ${trgt}) (attr: ${attr})\n" >/dev/stderr
printf "=============================================================================================================\n" >/dev/stderr

if [[ "$trgt" == *"cachix:"* ]]; then
  cachix_cache="$(echo "${trgt}" | cut -d ':' -f2)"
  trgt="cachix"
  # TODO: this is wrong:
  cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"
fi

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


printf "==>> ${attr}.outPath == ${_out}\n" >/dev/stderr
printf "==>> trgt == ${trgt}\n" >/dev/stderr
printf "==>> bldr == ${bldr}\n" >/dev/stderr

printf "\n==:: nix copy (derivations)\n" >/dev/stderr
nix copy --derivation "${_drv}" \
  --eval-store "auto" \
  --to "ssh-ng://${bldr}" \
  --no-check-sigs \
    >/dev/stderr

if [[ "${trgt}" != "cachix" ]]; then
  printf "==:: nix copy (direct)\n" >/dev/stderr
  nix copy "${_drv}" "${@}" \
    --builders-use-substitutes \
    --eval-store "auto" \
    --from "ssh-ng://${bldr}" \
    --to "ssh-ng://${trgt}" \
    --no-check-sigs \
      >/dev/stderr
else
  printf "==:: nix build\n" >/dev/stderr
  nix build "${_drv}" "${@}" \
    --builders-use-substitutes \
    --eval-store "auto" \
    --store "ssh-ng://${bldr}" \
    --keep-going \
      >/dev/stderr

  printf "==:: push to cachix\n" >/dev/stderr
  ssh "${bldr}" "echo \"${_out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" tee /dev/stderr | cachix push ${cachix_cache} >/dev/stderr" >&2
fi

printf "${_out}"
