#!/usr/bin/env bash
DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
set -euo pipefail

bldr="${1}"; shift
trgt="${1}"; shift
attr="${1}"; shift


if [[ "$trgt" == *"cachix:"* ]]; then
  cachix_cache="$(echo "${trgt}" | cut -d ':' -f2)"
  cachix_key="$(cat /run/secrets/cachix_signkey_colemickens)"
fi

## EVAL
printf "==:: nixbuild: eval: '${attr}'\n" >&2

_json="$(nix eval --json "${attr}" "${@}" \
  --apply "x: { out=x.outPath; drv=x.drvPath; sys=x.system; }")"
_drv="$(echo "${_json}" | jq -r '.drv')"
_out="$(echo "${_json}" | jq -r '.out')"
_sys="$(echo "${_json}" | jq -r '.sys')"

## BUILD
printf "==:: nixbuild: build [drv: ${_drv}]\n" >&2
printf "==:: nixbuild: build [out: ${_out}]\n" >&2

# auto-select builder based on derivation system
if [[ "${bldr}" == "auto" ]]; then
  # TODO: make sure we're checking the right attribute
  # we might be wanting to checking hostBuildPlat or whatever
  case "${_sys}" in
    "aarch64-linux") _bldr="${BLDR_A64}"; ;;
    "armv6l-linux") _bldr="${BLDR_X86}"; ;;
    "x86_64-linux") _bldr="${BLDR_X86}"; ;;
  esac
else
  _bldr="${bldr}"
fi

printf "==:: nixbuild: copy drvs (to: ${bldr})\n" >&2
nix copy --derivation "${_drv}" \
  --eval-store "auto" \
  --to "ssh-ng://${_bldr}" \
  --no-check-sigs \
    >&2

log="$(mktemp --tmpdir "nixbuild-XXXXXXXX")"
trap "rm ${log}" EXIT
while true; do
  printf "==:: nixbuild: build (on: ${bldr}) (log: ${log})\n" >&2
  set +e ####################
  stdbuf -i0 -o0 -e0 \
    nix build "${_drv}" \
      --builders-use-substitutes \
      --eval-store "auto" \
      --store "ssh-ng://${_bldr}" \
      --keep-going 2>&1 \
        | tee "${log}" >&2
  exitcode="${PIPESTATUS[0]}";
  set -e ####################
  if [[ "${exitcode}" == 0 ]]; then
    printf "==:: nixbuild: build: success\n" >&2
    break
  elif cat "${log}" | rg "requires non-existent output" &>/dev/null; then
    printf "==:: nixbuild: build: retry (bug: nixos/nix#6572)\n" >&2
    continue
  elif cat "${log}" | rg "signal 9" &>/dev/null; then
    printf "==:: nixbuild: build: retry (oom)\n" >&2
    continue
  fi
  printf "==:: nixbuild: build: fatal failure\n" >&2
  exit "${exitcode}"
done

if [[ "$trgt" == *"cachix:"* ]]; then
  printf "==:: nixbuild: push to cachix\n" >&2
  ssh "${_bldr}" "env CACHIX_SIGNING_KEY=\"${cachix_key}\" echo \"${_out}\" | cachix push ${cachix_cache} >&2" >&2
fi

printf "==:: nixbuild: done\n" >&2
printf "${_out}"
printf "\n" >&2
