#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail

bldr="${1}"; shift
trgt="${1}"; shift
attr="${1}"; shift; name="$(echo "${attr}" | cut -d '#' -f2-)"

printf "==:: eval: [attr: ${attr}]\n" >/dev/stderr

if [[ "$trgt" == *"cachix:"* ]]; then
  cachix_cache="$(echo "${trgt}" | cut -d ':' -f2)"
  trgt="cachix"
  # TODO: this is wrong:
  cachix_key="$(cat /run/secrets/cachix.dhall | grep "eIu" | cut -d '"' -f2)"
fi

_json="$(nix eval --json "${attr}" "${@}" \
  --apply "x: { out=x.outPath; drv=x.drvPath; sys=x.system; }")"
_drv="$(echo "${_json}" | jq -r '.drv')"
_out="$(echo "${_json}" | jq -r '.out')"
_sys="$(echo "${_json}" | jq -r '.sys')"

printf "==:: build [drv: ${_drv}]\n" >/dev/stderr
printf "==:: build [out: ${_out}]\n" >/dev/stderr

# TODO: make sure we're checking the right attribute
# we might be wanting to checking hostBuildPlat or whatever
if [[ "${bldr}" == "auto" ]]; then
  case "${_sys}" in
    "aarch64-linux") _bldr="${BLDR_A64}"; ;;
    "armv6l-linux") _bldr="${BLDR_X86}"; ;;
    "x86_64-linux") _bldr="${BLDR_X86}"; ;;
  esac
else
  _bldr="${bldr}"
fi

printf "==:: build: copy drvs (to: ${bldr})\n" >/dev/stderr
nix copy --derivation "${_drv}" \
  --eval-store "auto" \
  --to "ssh-ng://${_bldr}" \
  --no-check-sigs \
    >/dev/stderr

retry=1
while [[ "${retry}" == 1 ]]; do
  retry=0
  if [[ "${trgt}" != "cachix" ]]; then
    printf "==:: build: copy (from: ${bldr}) (to: ${trgt})\n" >/dev/stderr
    nix copy "${_drv}" "${@}" \
      --builders-use-substitutes \
      --eval-store "auto" \
      --from "ssh-ng://${_bldr}" \
      --to "ssh-ng://${trgt}" \
      --no-check-sigs \
        >/dev/stderr
  else
    printf "==:: build: build (on: ${bldr})\n" >/dev/stderr
    set -x
    set +e
    stdbuf -i0 -o0 -e0 \
      nix build "${_drv}" "${@}" \
        --builders-use-substitutes \
        --eval-store "auto" \
        --store "ssh-ng://${_bldr}" \
        --keep-going \
          |& tee /tmp/l >/dev/stderr

      if cat /tmp/l | rg "requires non-existent output"; then
        retry=1
      fi
    set -e
    set +x

    printf "==:: build: push to cachix\n" >/dev/stderr
    ssh "${_bldr}" "echo \"${_out}\" | env CACHIX_SIGNING_KEY=\"${cachix_key}\" tee /dev/stderr | cachix push ${cachix_cache} >/dev/stderr" >&2
  fi
done

exitcode=0
printf "==:: build: exitcode=${exitcode}\n" >/dev/stderr
printf "${_out}"
exit "${exitcode}"
