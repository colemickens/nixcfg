#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
set -x

function nix() { "${DIR}/nix.sh" "${@}"; }

# {copy_method} {activate_action} {remote_builder} {target} {thing}

copymethod="${1}"; shift
action="${1}"; shift
remote="${1}"; shift
target="${1}"; shift
thing="${1}"; shift

drv="$(nix eval --raw "${DIR}/..#${thing}.drvPath" "${@}")"
out="$(nix eval --raw "${DIR}/..#${thing}" "${@}")"

#### build + copy

if [[ "${copymethod}" == *new* ]]; then
  nix build --store "ssh-ng://${remote}" --eval-store auto "${thing}"
  if [[ "${copymethod}" == *copy* ]]; then
    nix copy --from "ssh-ng://${remote}" "${thing}"
  elif [[ "${copymethod}" == *cachix* ]]; then
    false # TODO: cachix
  fi
elif [[ "${copymethod}" == *old** ]]; then
  workdir="/tmp/rbuild-$(echo "${thing}" | sha256sum | cut -d' ' -f1)"
  nix copy --to "file://${workdir}" --derivation "${drv}"
  rsync -avh "${workdir}/" "[${remote}]":"${workdir}/"

  ssh "${remote}" "nix copy --derivation --from \"file://${workdir}\" \"${drv}\""
  ssh "${remote}" "nix build -L \"${drv}\" --no-link"

  if [[ "${copymethod}" == *copy* ]]; then
    ssh "${remote}" "nix copy --to \"file://${workdir}\" \"${out}\""
    rsync -avh "[${remote}]":"${workdir}/" "${workdir}/"
    nix copy --no-check-sigs --from "${workdir}" "${out}"
  elif [[ "${copymethod}" == *cachix ]]; then
    false # TODO: cachix
  fi
# elif [[ "${copymethod}" == *git* ]]; then
#   # copy from mobuild
#   # git commit, push
#   # ON REMOTE:
#   # make sure ~/code/nixcfg exists
#   # remote update; reset --hard HEAD
#   git -C /home/cole/code/nixcfg commit . -m "wip" || true
#   git -C /home/cole/code/nixcfg push origin HEAD

#   ssh "colemickens@aarch64.nixos.community" "git -C /home/colemickens/code/nixcfg remote update \
#     && git -C /home/colemickens/code/nixcfg reset --hard origin/main \
#     && nix build -L /home/colemickens/code/nixcfg#${thing} --keep-going --out-link /tmp/${out}"

#   true
#   if [[ "${copymethod}" == *copy* ]]; then
#     nix copy --from "ssh-ng://${remote}" "${thing}"
#   elif [[ "${copymethod}" == *cachix ]]; then
#     false # TODO: cachix
#   fi
fi

if [[ "${action:-""}" == *activate* ]]; then
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" build --no-link --profile /nix/var/nix/profiles/system "${out}")"
  ssh "${target}" "$(printf '\"%s\" ' sudo nix "${nixargs[@]}" shell -vv "${out}" -c switch-to-configuration switch)"
fi
if [[ "${action:-""}" == *reboot* ]]; then ssh "${target}" "sudo reboot"; fi

#### whew
echo "done"
