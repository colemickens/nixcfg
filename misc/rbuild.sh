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

drv="$(nix eval --raw "${thing}.drvPath" "${@}")"
out="$(nix eval --raw "${thing}" "${@}")"

nix copy --derivation --eval-store "auto" --no-check-sigs --to "ssh-ng://${remote}" "${drv}"

aaargs=(--eval-store "auto" --no-check-sigs)
if [[ "${remote}" != "localhost" ]]; then
  aaargs=("${aaargs[@]}" --from "ssh-ng://${remote}")
fi
if [[ "${target}" != "localhost" ]]; then
  aaargs=("${aaargs[@]}" --to "ssh-ng://${target}")
fi
nix copy "${aaargs[@]}" "${thing}" "${@}"

# #### build + copy

# if [[ "${copymethod}" == *new* ]]; then
#   printf "%s" "***************\n***************\nshould we have to copy the drv manually with --eval-store like this?***************\n***************\n" >/dev/stderr
#   nix copy --eval-store "auto" --no-check-sigs --from "ssh-ng://${remote}" --to "ssh-ng://${target}" "${@}"

#   if [[ "${copymethod}" == *cachix* ]]; then
#     echo "${out}" | cachix push "${cachix_cache}"
#   fi
# elif [[ "${copymethod}" == *old** ]]; then
#   workdir="/tmp/rbuild-$(echo "${thing}" | sha256sum | cut -d' ' -f1)"
#   nix copy --to "file://${workdir}" --derivation "${drv}"
#   rsync -avh "${workdir}/" "[${remote}]":"${workdir}/"

#   ssh "${remote}" "nix copy --derivation --from \"file://${workdir}\" \"${drv}\""
  
#   #### Test: instead:
#   #####ssh "${remote}" "nix build -L \"${drv}\" --no-link --keep-going"
#   nix build --store "ssh-ng://${remote}" --eval-store auto "${drv}" --keep-going
#   #####

#   if [[ "${copymethod}" == *rsync* ]]; then
#     ssh "${remote}" "nix copy --to \"file://${workdir}\" \"${out}\""
#     rsync -avh "[${remote}]":"${workdir}/" "${workdir}/"
#     nix copy --no-check-sigs --from "${workdir}" "${out}"
#   elif [[ "${copymethod}" == *copy* ]]; then
#     nix copy --no-check-sigs --from "ssh-ng://${remote}" --to "ssh-ng://${target}" "${out}"
#   elif [[ "${copymethod}" == *cachix ]]; then
#     false # TODO: cachix
#   fi
# fi

if [[ "${action:-""}" == *activate* ]]; then
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --no-link --profile /nix/var/nix/profiles/system "${out}")"
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${out}" -c switch-to-configuration switch)"
fi
if [[ "${action:-""}" == *reboot* ]]; then ssh "${target}" "sudo reboot"; fi

#### whew
echo "done" > /dev/stderr
echo "${out}" > /dev/stdout
