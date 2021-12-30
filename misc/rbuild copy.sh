#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
set -x

cachix_cache="colemickens"

function nix() { "${DIR}/nix.sh" "${@}"; }

# {copy_method} {activate_action} {remote_builder} {target} {thing}

copymethod="${1}"; shift
action="${1}"; shift
remote="${1}"; shift
target="${1}"; shift
thing="${1}"; shift

# lol "caching" in 2.4, ooookay.
# TMPDRV="$(mktemp)"; #trap "rm ${TMPDRV}" EXIT;
# nix build --derivation "${thing}.inputDerivation" "${@}" > "${TMPDRV}"
# drv="$(jq -r .drvPath <"${TMPDRV}")"
# out="$(jq -r .out[0].path <"${TMPDRV}")"

# caching doens't work or I woulnd't have to wait so fucking long for this to eval again:
drv="$(nix eval --raw "${thing}.drvPath" "${@}")"
out="$(nix eval --raw "${thing}" "${@}")"

#### build + copy

if [[ "${copymethod}" == *new* ]]; then
  printf "%s" "***************\n***************\nshould we have to copy the drv manually with --eval-store like this?***************\n***************\n" >/dev/stderr
  nix copy --no-check-sigs --to "ssh-ng://${remote}" --derivation "${drv}"
  nix build -L --store "ssh-ng://${remote}" --eval-store auto "${drv}" --keep-going
  
  if [[ "${copymethod}" == *copy* ]]; then
    nix copy --no-check-sigs --from "ssh-ng://${remote}" --to "ssh-ng://${target}" "${out}"
  fi

  if [[ "${copymethod}" == *cachix* ]]; then
    echo "${out}" | cachix push "${cachix_cache}"
  fi
elif [[ "${copymethod}" == *old** ]]; then
  workdir="/tmp/rbuild-$(echo "${thing}" | sha256sum | cut -d' ' -f1)"
  nix copy --to "file://${workdir}" --derivation "${drv}"
  rsync -avh "${workdir}/" "[${remote}]":"${workdir}/"

  ssh "${remote}" "nix copy --derivation --from \"file://${workdir}\" \"${drv}\""
  
  #### Test: instead:
  #####ssh "${remote}" "nix build -L \"${drv}\" --no-link --keep-going"
  nix build --store "ssh-ng://${remote}" --eval-store auto "${drv}" --keep-going
  #####

  if [[ "${copymethod}" == *rsync* ]]; then
    ssh "${remote}" "nix copy --to \"file://${workdir}\" \"${out}\""
    rsync -avh "[${remote}]":"${workdir}/" "${workdir}/"
    nix copy --no-check-sigs --from "${workdir}" "${out}"
  elif [[ "${copymethod}" == *copy* ]]; then
    nix copy --no-check-sigs --from "ssh-ng://${remote}" --to "ssh-ng://${target}" "${out}"
  elif [[ "${copymethod}" == *cachix ]]; then
    false # TODO: cachix
  fi
fi

if [[ "${action:-""}" == *activate* ]]; then
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --no-link --profile /nix/var/nix/profiles/system "${out}")"
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${out}" -c switch-to-configuration switch)"
fi
if [[ "${action:-""}" == *reboot* ]]; then ssh "${target}" "sudo reboot"; fi

#### whew
echo "done" > /dev/stderr
echo "${out}" > /dev/stdout
