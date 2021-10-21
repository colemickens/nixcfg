#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
set -x

function nix() { "${DIR}/nix.sh" "${@}"; }

# {thing} {remote} {cachix|newcopy|oldcopy}
thing="${1}"; shift
remote="${2:-"colemickens@aarch64.nixos.community"}"
copymethod="${3:-"oldcopy"}"

drv="$(nix eval --raw "${DIR}/..#${thing}.drvPath")"
out="$(nix eval --raw "${DIR}/..#${thing}")"

#### build + copy

if [[ "${copymethod}" == new* ]]; then
  nix build --store "ssh-ng://${remote}" --eval-store auto "${thing}"
  if [[ "${copymethod}" == *copy ]]; then
    nix copy --from "ssh-ng://${remote}" "${thing}"
  elif [[ "${copymethod}" == *cachix ]]; then
    false # TODO: cachix
  fi
elif [[ "${copymethod}" == old** ]]; then
  workdir="/tmp/$(echo "${thing}" | sha256sum | cut -d' ' -f1)"
  nix copy --to "file://${workdir}" --derivation "${drv}"
  rsync -avh "${workdir}/" "${remote}":"${workdir}/"

  ssh "${remote}" "nix copy --from \"file://${workdir}\" \"${drv}\""
  ssh "${remote}" "nix build -L \"${drv}\" --no-out-link"

  if [[ "${copymethod}" == *copy ]]; then
    ssh "${remote}" "nix copy --to \"file://${workdir}\" \"${out}\""
    rsync -avh "${remote}":"${workdir}/" "${workdir}/"
    nix copy --no-check-sigs --from "${workdir}" "${out}"
  elif [[ "${copymethod}" == *cachix ]]; then
    false # TODO: cachix
  fi
fi


# function _remote() {
#   set -euo pipefail
#   remote="${1}"; buildattr="${2}"; target="${3}"; action="${4:-""}"
#   out="$(nix eval --raw "${buildattr}")"
#   #_nix copy --to "ssh-ng://${remote}" --derivation "${buildattr}" --no-check-sigs
#   _nix build --store "ssh-ng://${remote}" --eval-store "auto" "${buildattr}" |& tee /tmp/nb
#   if [[ "${action}" == *cachix* ]]; then
#     echo "${out}" | ssh "${remote}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" run nixpkgs/nixos-unstable#cachix push "${cache}")"
#     ssh "${target}" "$(printf '\"%s\" ' sudo nix-store "${nixargs[@]}" -r "${out}")"
#   else nix copy --no-check-sigs --from "ssh-ng://${remote}" --to "ssh-ng://${target}" "${out}"
#   fi
#   if [[ "${action:-""}" == *activate* ]]; then
#     ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --no-link --profile /nix/var/nix/profiles/system "${out}")"
#     ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${out}" -c switch-to-configuration switch)"
#   fi
#   if [[ "${action:-""}" == *reboot* ]]; then ssh "${target}" "sudo reboot"; fi
# }

#### whew
echo "done"
